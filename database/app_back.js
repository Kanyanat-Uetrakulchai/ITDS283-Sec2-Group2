const express = require('express');
const dotenv = require('dotenv');
const mysql = require('mysql2');
const path = require("path");

const app = express();

dotenv.config();

const router = express.Router();
app.use(router);

var Connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME
});

/* เชื่อมต่อ Connect ไปที่ฐานข้อมูล */
Connection.connect(function (err) {
    if (err) throw err;
    console.log(`Connected DB: ${process.env.DB_NAME}`);
})

// Testing Select ALL Posts
// method: GET
// URL: http://localhost:3031/api/posts
// router.get('/api/posts', function (req, res) {
//     Connection.query('SELECT * FROM Post', function (error, results) {
//         if (error) throw error;
//         return res.send({ error: false, data: results, message: 'Posts retrieved.' });
//     });
// });

router.get('/api/posts', function (req, res) {
    Connection.query('SELECT p.caption, p.p_timestamp, u.profile, u.username FROM Post p INNER JOIN Users u on p.uid = u.uid ORDER BY p.p_timestamp DESC', function (error, results) {
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

/* Bind server เข้ากับ Port ที่กำหนด */
app.listen(process.env.PORT, () => {
    console.log(`Server listening on port: ${process.env.PORT}`);
});