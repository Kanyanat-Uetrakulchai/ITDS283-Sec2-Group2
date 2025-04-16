const express = require('express');
const dotenv = require('dotenv');
const mysql = require('mysql2');
const path = require("path");
const multer = require('multer');

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
    Connection.query('SELECT p.*, u.profile, u.username FROM Post p INNER JOIN Users u on p.uid = u.uid ORDER BY p.p_timestamp DESC', function (error, results) {
        if (error) throw error;
        return res.send({ error: false, data: results, message: 'Posts retrieved.' });
    });
});

router.get('/api/posts/:tag', function (req, res) {
    let tag = req.params.tag
    Connection.query('SELECT p.*, u.profile, u.username FROM (Post p INNER JOIN Users u on p.uid = u.uid)INNER JOIN Tags t on p.postId = t.postId ORDER BY p.p_timestamp DESC', function (error, results) {
        if (error) throw error;
        return res.send({ error: false, data: results, message: 'Posts retrieved.' });
    });
});

router.get('/api/pop_tags', function (req, res){
    Connection.query('SELECT t.tag, COUNT(p.postId) FROM post p RIGHT JOIN tags t ON p.postId = t.postId GROUP BY t.tag ORDER BY COUNT(p.postId) DESC LIMIT 4;', function (error, results){
        if (error) throw error;
        return res.send({error: false, data: results, message: 'Popular tags retrieved'})
    })
});

router.get('/api/post/:postId', function (req, res){
    let postId = req.params.postId
    Connection.query('SELECT * FROM Post WHERE postId = ?;',postId, function (error, results){
        if (error) throw error;
        return res.send({error: false, data: results, message: 'Post retrieved'})
    })
});

router.get('/api/profile/post/:uid', function (req, res){
    let uid = req.params.uid
    Connection.query('SELECT * FROM Post JOIN Users ON Post.uid = Users.uid WHERE Users.uid = ? ORDER BY p_timestamp DESC;',uid, function (error, results){
        if (error) throw error;
        return res.send({error: false, data: results, message: 'Post retrieved'})
    })
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
      (SELECT COUNT(*) FROM Likes WHERE postId = ?) AS likes,
      (SELECT COUNT(*) FROM Likes WHERE postId = ? AND reaction = 'unlike') AS unlikes,
      (SELECT reaction FROM Likes WHERE postId = ? AND uid = ?) AS reaction
  `;

  Connection.query(sql, [postId, postId, postId, userId], function (error, results) {
    if (error) {
      console.error(error);
      return res.status(500).send({ error: true, message: "Database error" });
    }

    const row = results[0];
    res.send({
      error: false,
      likes: row.likes,
      unlikes: row.unlikes,
      reaction: row.reaction || null
    });
  });
});

router.post('/api/login', function (req, res) {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).send({
            success: false,
            message: 'Please provide username and password'
        });
    }

    Connection.query(
        'SELECT uid FROM Users WHERE username = ? AND password = ?',
        [username, password],
        function (error, results) {
            if (error) {
                return res.status(500).send({
                    success: false,
                    message: 'Database error',
                    error
                });
            }

            if (results.length > 0) {
                return res.send({
                    success: true,
                    uid: results[0].uid,
                    message: 'Login successful'
                });
            } else {
                return res.send({
                    success: false,
                    message: 'Invalid username or password'
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
app.post('/api/user/register', (req, res) => {
  const { username, password } = req.body;
  const joinDate = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format

  // Validate input
  if (!username || !password) {
    return res.status(400).json({ error: true, message: 'Username and password are required' });
  }

  // Check if username exists
  Connection.query(
    'SELECT * FROM Users WHERE username = ?', 
    [username],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: true, message: 'Database error' });
      }
      
      if (results.length > 0) {
        return res.status(400).json({ error: true, message: 'Username already exists' });
      }

      // Insert new user
      Connection.query(
        'INSERT INTO Users (username, password, joinDate) VALUES (?, ?, ?)',
        [username, password, joinDate],
        (err, results) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to register user' });
          }
          
          res.status(201).json({ 
            message: 'User registered successfully',
            uid: results.insertId
          });
        }
      );
    }
  );
});

  

/* Bind server เข้ากับ Port ที่กำหนด */
app.listen(process.env.PORT, () => {
    console.log(`Server listening on port: ${process.env.PORT}`);
});