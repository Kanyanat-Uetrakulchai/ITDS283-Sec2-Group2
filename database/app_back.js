const express = require('express');
const dotenv = require('dotenv');
const mysql = require('mysql2');
const path = require("path");
const multer = require('multer');
const crypto = require('crypto');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

dotenv.config();

const router = express.Router();
app.use(router);

var Connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME
});

app.use('/uploads', express.static('uploads'));

// Multer storage config
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '_' + Math.round(Math.random() * 1e9) + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});
const upload = multer({ storage: storage });

/* เชื่อมต่อ Connect ไปที่ฐานข้อมูล */
Connection.connect(function (err) {
    if (err) throw err;
    console.log(`Connected DB: ${process.env.DB_NAME}`);
})

router.get('/api/posts', function (req, res) {
  Connection.query(`
      SELECT 
          p.*, 
          u.profile, 
          u.username, 
          IFNULL(GROUP_CONCAT(DISTINCT t.tag), '') as tags
      FROM Post p 
      INNER JOIN Users u ON p.uid = u.uid
      LEFT JOIN Tags t ON p.postId = t.postId
      GROUP BY p.postId
      ORDER BY p.p_timestamp DESC
  `, function (error, results) {
      if (error) {
          console.error('Database error:', error);
          return res.status(500).send({ 
              error: true, 
              message: 'Failed to retrieve posts' 
          });
      }

      // Process results to convert empty tag string to empty array
      const processedResults = results.map(post => ({
          ...post,
          tags: post.tags ? post.tags.split(',').filter(tag => tag !== '') : []
      }));

      return res.send({ 
          error: false, 
          data: processedResults, 
          message: 'Posts retrieved successfully' 
      });
  });
});

router.get('/api/posts/:tag', function (req, res) {
  const tag = req.params.tag;
  
  if (!tag || typeof tag !== 'string') {
      return res.status(400).send({ 
          error: true, 
          message: 'Invalid tag parameter' 
      });
  }

  Connection.query(`
      SELECT 
          p.*, 
          u.profile, 
          u.username, 
          IFNULL(GROUP_CONCAT(DISTINCT t2.tag), '') as tags
      FROM Post p 
      INNER JOIN Users u ON p.uid = u.uid
      INNER JOIN Tags t ON p.postId = t.postId 
      LEFT JOIN Tags t2 ON p.postId = t2.postId
      WHERE t.tag = ? 
      GROUP BY p.postId
      ORDER BY p.p_timestamp DESC
  `, [tag], function (error, results) {
      if (error) {
          console.error('Database error:', error);
          return res.status(500).send({ 
              error: true, 
              message: 'Failed to retrieve posts' 
          });
      }

      // Process results to convert tags string to array
      const processedResults = results.map(post => ({
          ...post,
          tags: post.tags ? post.tags.split(',').filter(t => t !== '') : []
      }));

      return res.send({ 
          error: false, 
          data: processedResults, 
          message: 'Posts retrieved successfully' 
      });
  });
});

router.get('/api/pop_tags', function (req, res){
    Connection.query('SELECT t.tag, COUNT(p.postId) FROM post p RIGHT JOIN tags t ON p.postId = t.postId GROUP BY t.tag ORDER BY COUNT(p.postId) DESC LIMIT 4;', function (error, results){
        if (error) throw error;
        return res.send({error: false, data: results, message: 'Popular tags retrieved'})
    })
});

router.get('/api/post/:postId', function (req, res) {
  const postId = parseInt(req.params.postId);
  
  if (!postId || isNaN(postId)) {
      return res.status(400).send({ 
          error: true, 
          message: 'Invalid post ID' 
      });
  }

  Connection.query(`
      SELECT 
          p.*,
          u.username,
          u.profile,
          IFNULL(GROUP_CONCAT(DISTINCT t.tag), '') as tags
      FROM Post p
      LEFT JOIN Users u ON p.uid = u.uid
      LEFT JOIN Tags t ON p.postId = t.postId
      WHERE p.postId = ?
      GROUP BY p.postId
  `, [postId], function (error, results) {
      if (error) {
          console.error('Database error:', error);
          return res.status(500).send({ 
              error: true, 
              message: 'Failed to retrieve post' 
          });
      }

      if (results.length === 0) {
          return res.status(404).send({ 
              error: true, 
              message: 'Post not found' 
          });
      }

      const post = {
          ...results[0],
          tags: results[0].tags ? results[0].tags.split(',').filter(t => t !== '') : []
      };
      console.log(post);
      return res.send({ 
          error: false, 
          data: post, 
          message: 'Post retrieved successfully' 
      });
  });
});

router.get('/api/profile/post/:uid', function (req, res) {
  const uid = parseInt(req.params.uid);
  
  if (!uid || isNaN(uid)) {
      return res.status(400).send({ 
          error: true, 
          message: 'Invalid user ID' 
      });
  }

  Connection.query(`
      SELECT 
          p.*,
          u.username,
          u.profile,
          IFNULL(GROUP_CONCAT(DISTINCT t.tag), '') as tags
      FROM Post p
      JOIN Users u ON p.uid = u.uid
      LEFT JOIN Tags t ON p.postId = t.postId
      WHERE u.uid = ?
      GROUP BY p.postId
      ORDER BY p.p_timestamp DESC
  `, [uid], function (error, results) {
      if (error) {
          console.error('Database error:', error);
          return res.status(500).send({ 
              error: true, 
              message: 'Failed to retrieve posts' 
          });
      }

      const processedResults = results.map(post => ({
          ...post,
          tags: post.tags ? post.tags.split(',').filter(t => t !== '') : []
      }));
      return res.send({ 
          error: false, 
          data: processedResults, 
          message: 'Posts retrieved successfully' 
      });
  });
});

router.get('/api/post/detail/:postId', function (req, res){
  let postId = req.params.postId
  Connection.query('SELECT * FROM Post JOIN Users ON Post.uid = Users.uid WHERE Post.postId = ?;',postId, function (error, results){
      if (error) throw error;
      return res.send({error: false, data: results, message: 'Post retrieved'})
  })
});

router.get('/api/user/:uid', function (req, res){
    let uid = req.params.uid
    Connection.query('SELECT * FROM Users WHERE uid = ?;',uid, function (error, results){
        if (error) throw error;
        return res.send({error: false, data: results, message: 'User retrieved'})
    })
});

router.get('/api/reaction', function (req, res) {
  const postId = req.query.post_id;
  const userId = req.query.user_id;

  if (!postId || !userId) {
    return res.status(400).send({ error: true, message: "Missing post_id or user_id" });
  }

  const sql = `
    SELECT 
      (SELECT COUNT(*) FROM Likes WHERE postId = ? AND reaction = 'like') AS likes,
      (SELECT COUNT(*) FROM Likes WHERE postId = ? AND reaction = 'unlike') AS unlikes,
      (SELECT reaction FROM Likes WHERE postId = ? AND uid = ?) AS reaction
  `;

  Connection.query(sql, [postId, postId, postId, userId], function (error, results) {
    if (error) {
      console.error(error);
      return res.status(500).send({ error: true, message: "Database error" });
    }
    console.log(results)
    const row = results[0];
    res.send({
      error: false,
      likes: row.likes,
      unlikes: row.unlikes,
      reaction: row.reaction || null
    });
  });
});

// Search posts
router.post('/posts/search', async (req, res) => {
  try {
    const { bank, accountNumber, name, shopName, orderChannel, tag } = req.body;
    
    let baseQuery = `
      SELECT 
        p.*,
        GROUP_CONCAT(t.tag) as tags
      FROM Post p
      LEFT JOIN Tags t ON p.postId = t.postId
    `;
    
    const conditions = [];
    const params = [];
    
    if (bank) {
      conditions.push('p.mij_bank = ?');
      params.push(bank);
    }
    
    if (accountNumber) {
      conditions.push('p.mij_bankno LIKE ?');
      params.push(`%${accountNumber}%`);
    }
    
    if (name) {
      conditions.push('p.mij_name LIKE ?');
      params.push(`%${name}%`);
    }
    
    if (shopName) {
      conditions.push('p.mij_acc LIKE ?');
      params.push(`%${shopName}%`);
    }
    
    if (orderChannel) {
      conditions.push('p.mij_plat LIKE ?');
      params.push(`%${orderChannel}%`);
    }
    
    if (conditions.length > 0) {
      baseQuery += ' WHERE ' + conditions.join(' AND ');
    }
    
    baseQuery += ' GROUP BY p.postId';
    
    // If tag is specified, we need to filter after the initial query
    // or use a HAVING clause with FIND_IN_SET (less efficient)
    if (tag) {
      baseQuery = `
        SELECT * FROM (${baseQuery}) AS filtered_posts
        WHERE tags LIKE ? OR tags IS NULL
      `;
      params.push(`%${tag}%`);
    }
    
    const [rows] = await Connection.promise().query(baseQuery, params);
    
    // Process the results to convert tags string to array
    const posts = rows.map(row => {
      return {
        ...row,
        tags: row.tags ? row.tags.split(',') : []
      };
    });
    
    res.json({ posts });
  } catch (error) {
    console.error('Error searching posts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/api/login', function (req, res) {
  const { username, password } = req.body;

  if (!username || !password) {
      return res.status(400).send({
          success: false,
          message: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน'
      });
  }

  // Hash the received password to compare with stored hash
  const hashedPassword = crypto.createHash('sha256')
                             .update(password)
                             .digest('hex');

  Connection.query(
      'SELECT uid FROM Users WHERE username = ? AND password = ?',
      [username, hashedPassword], // Compare with stored hash
      function (error, results) {
          if (error) {
              console.error('Login error:', error);
              return res.status(500).send({
                  success: false,
                  message: 'Database error'
              });
          }

          if (results.length > 0) {
              return res.send({
                  success: true,
                  uid: results[0].uid,
                  message: 'เข้าสู่ระบบสำเร็จ'
              });
          } else {
              return res.send({
                  success: false,
                  message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'
              });
          }
      }
  );
});


router.post('/api/posts', upload.array('images', 4), (req, res) => {
    const {
      caption,
      detail,
      mij_bank,
      mij_bankno,
      mij_name,
      mij_acc,
      mij_plat,
      uid,
      p_timestamp
    } = req.body;
  
    if (
      !caption || !detail || !mij_bank || !mij_bankno ||
      !mij_name || !mij_acc || !mij_plat || !uid || !p_timestamp
    ) {
      return res.status(400).json({ error: true, message: 'Missing required fields' });
    }
  
    // Store up to 4 image paths
    const imagePaths = Array(4).fill(null);
    if (req.files && req.files.length > 0) {
      req.files.forEach((file, i) => {
        if (i < 4) imagePaths[i] = `/uploads/${file.filename}`;
      });
    }
  
    const sql = `
      INSERT INTO Post (
        caption, detail, mij_bank, mij_bankno, mij_name, mij_acc, mij_plat, p_timestamp, uid,
        p_p1, p_p2, p_p3, p_p4
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
  
    const values = [
      caption,
      detail,
      mij_bank,
      mij_bankno,
      mij_name,
      mij_acc,
      mij_plat,
      p_timestamp,
      uid,
      imagePaths[0],
      imagePaths[1],
      imagePaths[2],
      imagePaths[3]
    ];
  
    Connection.execute(sql, values, (err, results) => {
      if (err) return res.status(500).json({ error: true, message: err.message });
  
      res.status(201).json({
        success: true,
        message: 'Post created successfully',
        postId: results.insertId,
        imagePaths
      });
    });
  });
  
router.post('/react', async (req, res) => {
    const { post_id, user_id, reaction } = req.body; // reaction = 'like', 'unlike', or empty
  
    const [existing] = await Connection.promise().query(
      'SELECT reaction FROM Likes WHERE postId = ? AND uid = ?',
      [post_id, user_id]
    );
  
    if (!reaction || (existing.length && existing[0].reaction === reaction)) {
      // Toggle off: delete row
    await Connection.promise().query(
        'DELETE FROM Likes WHERE postId = ? AND uid = ?',
        [post_id, user_id]
      );
    } else if (existing.length) {
      // Change reaction
    await Connection.promise().query(
        'UPDATE Likes SET reaction = ? WHERE postId = ? AND uid = ?',
        [reaction, post_id, user_id]
      );
    } else {
      // New reaction
    await Connection.promise().query(
        'INSERT INTO Likes (postId, uid, reaction) VALUES (?, ?, ?)',
        [post_id, user_id, reaction]
      );
    }
  
    res.json({ success: true});
});

// POST /api/tags
router.post('/api/tags', async (req, res) => {
  const { postId, tags } = req.body;

  if (!postId || !Array.isArray(tags)) {
    return res.status(400).json({ error: 'Invalid request body' });
  }

  try {
    const placeholders = tags.map(() => '(?, ?)').join(', ');
    const values = tags.flatMap(tag => [postId, tag]);

    await Connection.promise().query(`INSERT INTO Tags (postId, tag) VALUES ${placeholders}`, values);
    console.log('Tags inserted');
    res.status(201).json({ message: 'Tags inserted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Post New User Infomation
app.post('/api/user/register', async (req, res) => {
  try {
    const { username, password } = req.body;
    const joinDate = new Date().toISOString().split('T')[0];

    // Validate input
    if (!username || !password) {
      return res.status(400).json({ 
        error: true, 
        message: 'ต้องระบุชื่อผู้ใช้งานและรหัสผ่าน' 
      });
    }

    if (password.length < 6) {
      return res.status(400).json({ 
        error: true, 
        message: 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร' 
      });
    }

    // Check if username exists
    const [existingUser] = await new Promise((resolve, reject) => {
      Connection.query(
        'SELECT * FROM Users WHERE username = ?', 
        [username],
        (err, results) => err ? reject(err) : resolve(results)
      );
    });

    if (existingUser) {
      return res.status(400).json({ 
        error: true, 
        message: 'ชื่อผู้ใช้งานนี้มีอยู่แล้ว' 
      });
    }

    // Hash the password
    const hashedPassword = crypto.createHash('sha256')
                               .update(password)
                               .digest('hex');

    // Insert new user
    const result = await new Promise((resolve, reject) => {
      Connection.query(
        'INSERT INTO Users (username, password, joinDate) VALUES (?, ?, ?)',
        [username.trim(), hashedPassword, joinDate],
        (err, results) => err ? reject(err) : resolve(results)
      );
    });

    res.status(201).json({ 
      success: true,
      message: 'ลงทะเบียนสำเร็จ',
      uid: result.insertId
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      error: true, 
      message: 'เกิดข้อผิดพลาดในระบบ' 
    });
  }
});

router.get('/api/follow/status', async (req, res) => {
  const { postId, uid } = req.query;
  Connection.query(
    'SELECT COUNT(*) as count FROM Follow WHERE postId = ? AND uid = ?',
    [postId, uid],
    (err, results) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: 'Database error' });
      }
      const isFollowed = results[0].count > 0;
      res.json({ isFollowed });
    }
  );
});


router.post('/api/follow', function (req, res){
  const { postId, uid, f_timestamp } = req.body;
  Connection.query('INSERT INTO Follow (postId, uid, f_timestamp) VALUES (?, ?, ?)',[postId, uid, f_timestamp], function (error, results){
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to follow' });
      }
      
      res.status(201).json({ 
        message: 'Followed post successfully'
      });
    }
  })
});

router.delete('/api/unfollow', function (req, res){
  const { postId, uid } = req.body;
  Connection.query('DELETE FROM Follow WHERE postId = ? AND uid = ?',[postId, uid], function (error, results){
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to unfollow' });
      }
      
      res.status(201).json({ 
        message: 'Unfollowed post successfully'
      });
    }
  })
});

app.get('/api/following/posts/:uid', (req, res) => {
  const uid = req.params.uid;

  if (!uid) {
    return res.status(400).json({ error: 'Missing uid' });
  }

  const sql = `
    SELECT 
      p.*, u.username 
    FROM Follow f
    INNER JOIN Post p ON f.postId = p.postId 
    INNER JOIN Users u ON p.uid = u.uid 
    WHERE f.uid = ? 
    ORDER BY p.p_timestamp DESC
  `;

  Connection.query(sql, [uid], (err, results) => {
    if (err) {
      console.error('DB Error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    res.json({ error: false, data: results });
  });
});


// Update Password
router.put('/api/user/:uid', async function (req, res) {
  try {
    const uid = req.params.uid;
    const { password, old_password } = req.body;

    // Validate required fields
    if (!password || !old_password) {
      return res.status(400).json({
        error: true,
        message: 'กรุณากรอกทั้งรหัสผ่านเก่าและรหัสผ่านใหม่'
      });
    }

    // First get the user's current password hash from database
    const [user] = await new Promise((resolve, reject) => {
      Connection.query(
        'SELECT password FROM Users WHERE uid = ?', 
        [uid], 
        (error, results) => {
          if (error) return reject(error);
          resolve(results);
        }
      );
    });

    if (!user) {
      return res.status(404).json({
        error: true,
        message: 'ไม่มีข้อมูลผู้ใช้นี้'
      });
    }

    // Verify old password matches (compare hashes)
    const oldPasswordHash = crypto.createHash('sha256')
                                 .update(old_password)
                                 .digest('hex');

    if (oldPasswordHash !== user.password) {
      return res.status(401).json({
        error: true,
        message: 'รหัสผ่านเก่าผิด'
      });
    }

    // Update with new hashed password
    const newPasswordHash = crypto.createHash('sha256')
                                 .update(password)
                                 .digest('hex');

    const results = await new Promise((resolve, reject) => {
      Connection.query(
        'UPDATE Users SET password = ? WHERE uid = ?', 
        [newPasswordHash, uid], 
        (error, results) => {
          if (error) return reject(error);
          resolve(results);
        }
      );
    });

    return res.json({
      error: false,
      data: results,
      message: 'เปลี่ยนรหัสผ่านสำเร็จ'
    });

  } catch (error) {
    console.error('Password update error:', error);
    return res.status(500).json({
      error: true,
      message: 'Internal server error'
    });
  }
});

router.post('/api/comment',upload.array('images', 4), (req, res) => {
  const { postId, uid, message, c_timestamp } = req.body;

  // Ensure required fields are provided
  if (!postId || !uid || !message || !c_timestamp) {
    return res.status(400).json({ error: true, message: 'Missing required fields' });
  }

  // Store up to 4 image paths
  const imagePaths = Array(4).fill(null);
  if (req.files && req.files.length > 0) {
    req.files.forEach((file, i) => {
      if (i < 4) imagePaths[i] = `/uploads/${file.filename}`;
    });
  }

  const sql = `
    INSERT INTO Comments (
      postId, uid, message, c_timestamp,
      c_p1, c_p2, c_p3, c_p4
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `;

  const values = [
    postId,
    uid,
    message,
    c_timestamp,
    imagePaths[0],
    imagePaths[1],
    imagePaths[2],
    imagePaths[3]
  ];
  
  // Execute the SQL query
  Connection.execute(sql, values, (err, results) => {
    if (err) return res.status(500).json({ error: true, message: err.message });

    // Respond with success and the comment's details
    res.status(201).json({
      success: true,
      message: 'Comment submitted successfully',
      commentId: results.insertId,
      imagePaths
    });
  });
});

router.get('/api/comment/:postId', async (req, res) => {
  const { postId } = req.params;
  const sql = `
    SELECT c.*, u.username
    FROM Comments c
    JOIN Users u ON c.uid = u.uid
    WHERE c.postId = ?
    ORDER BY c.c_timestamp DESC
  `;
  try {
    const [results] = await Connection.promise().query(sql, [postId]);
    // prepend domain if needed
    const comments = results.map(comment => ({
      ...comment,
      image_url: comment.image_url
        ? `${process.env.DOMAIN || 'http://localhost:3000'}${comment.image_url}`
        : null
    }));
    res.json({ data: comments });
  } catch (err) {
    res.status(500).json({ error: 'Error fetching comments' });
  }
});

/* Bind server เข้ากับ Port ที่กำหนด */
app.listen(process.env.PORT, () => {
    console.log(`Server listening on port: ${process.env.PORT}`);
});