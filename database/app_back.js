const express = require('express');
const dotenv = require('dotenv');
const mysql = require('mysql2');
const path = require("path");
const multer = require('multer');

const app = express();
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

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
      const uniqueName = Date.now() + '_' + Math.round(Math.random() * 1e9) + path.extname(file.originalname);
      cb(null, uniqueName);
    }
  });

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
    Connection.query('SELECT p.postId, p.caption, p.p_timestamp, u.profile, u.username FROM (Post p INNER JOIN Users u on p.uid = u.uid)INNER JOIN Tags t on p.postId = t.postId ORDER BY p.p_timestamp DESC', function (error, results) {
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

router.get('/api/post/profile/:uid', function (req, res){
    let uid = req.params.uid
    Connection.query('SELECT * FROM Post JOIN Users ON Post.uid = Users.uid WHERE Users.uid = ? ORDER BY p_timestamp DESC;',uid, function (error, results){
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


router.post('/api/upload-post-images', (req, res) => {
    upload(req, res, function (err) {
      if (err) return res.status(500).json({ status: 'error', message: err.message });
  
      const imagePaths = Array(4).fill(null);
      req.files.forEach((file, i) => {
        imagePaths[i] = `/uploads/${file.filename}`;
      });
  
      const sql = `
        INSERT INTO post (p_p1, p_p2, p_p3, p_p4)
        VALUES (?, ?, ?, ?)
      `;
  
      db.execute(sql, imagePaths, (error, results) => {
        if (error) return res.status(500).json({ status: 'error', message: error.message });
  
        res.json({ status: 'success', message: 'Images uploaded and saved', paths: imagePaths });
      });
    });
  });

/* Bind server เข้ากับ Port ที่กำหนด */
app.listen(process.env.PORT, () => {
    console.log(`Server listening on port: ${process.env.PORT}`);
});