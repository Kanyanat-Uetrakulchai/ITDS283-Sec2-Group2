create database if not exists mobile_s2_gr2;
use mobile_s2_gr2;
-- drop database mobile_s2_gr2;

create table if not exists Users (
	uid				int				not null	auto_increment,
    username		varchar(20)		not null,
    password		varchar(64)		not null,
    joinDate		date			not null,
    constraint		PK_users		primary key (uid)
);

create table if not exists Post (
	postId 			int 			not null	auto_increment,
    caption 		varchar(100),
    detail 			varchar(10000),
    mij_bank		varchar(20),
    mij_bankno		varchar(15),
    mij_name		varchar(50),
    mij_acc			varchar(50),
    mij_plat		varchar(20),
    p_timestamp		datetime,
    uid				int,
    p_p1			varchar(300),
    p_p2			varchar(300),
    p_p3			varchar(300),
    p_p4			varchar(300),
    constraint 		PK_post 		primary key (postId),
    constraint		FK_post			foreign key (uid) references Users(uid)
);

create table if not exists Tags(
	tag				varchar(50)		not null,
    postId			int				not null,
    constraint 		PK_tags 		primary key (tag,postId),
    constraint 		FK_tags 		foreign key (postId) references Post(postId)
);

create table if not exists Likes(
	postId			int				not null,
    uid				int				not null,
    reaction		ENUM('like', 'unlike')		not null,
    constraint		PK_likes 		primary key (postId, uid),
    constraint		FK_likes_p		foreign key (postId) references Post(postId),
    constraint		FK_likes_u		foreign key (uid) references Users(uid)
);

create table if not exists Comments(
	commId			int				not null	auto_increment,
    postId			int,
    uid				int,
    message			varchar(100),
    c_timestamp		datetime,
    c_p1			varchar(300),
    c_p2			varchar(300),
    c_p3			varchar(300),
    c_p4			varchar(300),
    constraint 		PK_comm 		primary key (commid),
    constraint		FK_comm_p		foreign key (postId) references Post(postId),
    constraint		FK_comm_u		foreign key (uid) references Users(uid)
);

create table if not exists Follow(
	postId			int 		not null,
    uid				int			not null,
    f_timestamp		datetime,
    constraint		PK_fol		primary key (postId, uid),
    constraint		FK_fol_p	foreign key (postId) references Post(postId),
    constraint		FK_fol_u	foreign key (uid) references Users(uid)
);

-- first post has to specify to initiate autoincrement
insert into Users values
	(1000001, 'admin', '0e69e6a4038df88d4c62c837edd7e04a95ea6368bca9d469e00ad766a2266770', '2025-03-01');

insert into Users values
	(null, 'member A', '82c9ba26e0411d99c408990245c55e2fafe31ce184a8059744e5e9ecf75920d9', '2025-03-03'),
	(null, 'InwZa007', 'bdb97cda1f92df61da059d650b27df3a50e1ac43bcc341662db8872bbcb33b77', '2025-03-05'),
    (null, 'I Love Cat', '3924f8a84c0a756b2c550dee412f093297f62a59c73c4a868194b5cb7cad30ec', '2025-03-08');
    
insert into Post values(
	null, 'เตือนภัยร้านขายของสัตว์เลี้ยง!!', 'เมื่อวานลองสั่งร้านขายของสัตว์เลี้ยงร้านใหม่ ในรูปดูดีมากกกก พอเปิดมา.. ไม่ ตรง ปก สุด สุด!! ถามร้านแล้วว่าแมวตัวเท่านี้ใส่ได้มั้ย ร้านตอบทันทีว่าได้ พอของมา.. เล็กขนาดนี้ให้หนูใส่รึเปล่า!? แถมที่นอนแมวด้ายหลุดรุ่ยเย็บไม่โอเคมากๆ😤
	พอทักไปที่ร้านก็บอกว่าจะคืนเงินให้แล้วหายไปเลย! สมัยนี้เชื่อใครได้บ้างเนี๊ย',
	'ธนาคารกรุงเทพ', '1234567890', 'มิจ เองจ้า', 'that one pet shop', 'shopee', '2025-04-04 17:17:17', 1000002, '/uploads/post1_example_shopee.jpg', null, null, null
);
    
insert into Post values(
	null, '‼️โดนร้านเติมเกมรีฟัน‼️', 'ตามหัวโพสต์เลยครับ ผมโดนร้านเติมเกมรีฟัน ปกติใช้บริการเขาตลอดไม่เคยมีปัญหา จู่ๆเมื่อวานเข้าเกมก็เจอว่าเพชรติดลบไปแล้ว... พอเข้าไปเช็คก็ชัดเจนครับปิดแอคเคาท์หนีไปแล้วแถมดูเหมือนจะไล่รีฟันทุกคนเลยด้วย',
    'ธนาคารกรุงศรี', '3698521470', 'นี่ก็มิจจ้า แต่ชื่อนัท', 'นัทดล ศรีสำรัฐ', 'X', '2025-04-08 20:20:20', 1000003, '/uploads/post_example_twitter.jpg', '/uploads/post_post_twitter.jpg', 
    '/uploads/post_chat_twitter.jpg', null
);

insert into Post values(
	null, 'หลอกขายเครื่อง ps มือสอง', 'คนขายเครื่อง ps ในกลุ่มเกม โอนแล้วยล็อกเลย',
    'ธนาคารกรุงศรี', '5555555555', 'รรรรร รอเรือกระรัน', 'รรรรร ระเรือกระรัน', 'facebook', '2025-04-08 20:20:20', 1000001, '/uploads/chat_example_p2.jpg', '/uploads/post_example_p2.jpg', null, null
);

insert into Post values(
	null, '📣 เตือนภัย‼ โดนโกงขนมสัตว์เลี้ยง – แชร์ไว้ให้ถึงคนโกง 🐶🐱', 'ขออนุญาตมาเตือนภัยค่ะ เราโดนโกงจากร้านขายขนมสัตว์ออนไลน์ อยากให้ทุกคนระวัง เพราะคนพวกนี้มันตั้งใจมาหลอกแบบเป็นระบบมากๆ
		\nเราเจอร้านนี้จากโพสต์ใน Facebook Marketplace เห็นว่ามีขายขนมสำหรับแมวหลายแบบ ทั้งอบแห้ง เนื้อปลา แท่งขัดฟัน ฯลฯ ราคาถูกกว่าปกติประมาณ 20-30% มีรูปสินค้าชัดเจน มีคนมากดไลก์ แชร์ และคอมเมนต์เหมือนมีลูกค้าจริงๆ ก็เลยสนใจ
        \nเราทักแชทไปถาม ทางร้านตอบไวมาก ให้คำแนะนำดีมาก พูดจาน่ารัก บอกว่า “ล็อตนี้หมดไวมากค่ะพี่ เพราะมาจากฟาร์มที่คุณหมอแนะนำ” แล้วก็อ้างว่ามีรีวิวเพียบ มีใบรับรองอาหารสัตว์จากต่างประเทศ
		\nพอเราตัดสินใจจะสั่ง ก็มีแพ็กเกจโปรโมชั่น 5 ถุง 390 บาท + ส่งฟรี บอกว่า “ให้โอนภายในครึ่งชั่วโมงนะคะ จะได้ล็อกของให้” เราก็โอนเลย เพราะคิดว่าไม่น่ามีอะไร แถมร้านดูจริงใจ
		\nหลังจากนั้น...
		\n⏳ ตอนแรกตอบปกติ บอกว่ากำลังแพ็กของ จะส่งเย็นนี้
		\n⏳ เย็นวันนั้นเงียบ... ถามไปก็ไม่ตอบ
		\n📵 เช้าวันต่อมา – บล็อกเฟซเราเรียบร้อยค่ะ
		\n🔍 พอใช้บัญชีอื่นเข้าไปดู – เพจหายไปแล้ว!', 'กสิกรไทย', '0381948271', ' มิจจี้ ทองประเสริฐ', 'PawLover Snacks - ขนมสัตว์เลี้ยงราคาน่ารัก', 'facebook',
        '2025-03-09', 1000004, '/uploads/post3_example_fb.jpg', null, null, null
);

insert into Post values (
	null, 'ร้านมะขามไม่ส่งของ😖', 'เรื่องมีอยู่ว่าเห็นร้านมะขามร้านนี้ในกลุ่มขายผลไม้ แถมจั่วไว้ว่าส่งฟรีในกรุงเทพด้วยเราก็เลยสั่งมา ตอนแรกก็ไม่มีอะไรเขาว่าส่งทุกจันทร์ก็เลยรอ
    /nพอวันจันทร์เราก็ทักไปถามเขาก็ถามที่อยู่อีกรอบ เรายังไม่คิดอะไรนึกว่าคงกำลังแพ็คส่งมั้ง แล้วด้วยความยุ่งๆ ลืมไปสนิทมานึกได้ตอนสิ้นเดือนว่ายังไม่ได้มะขามนี่หว่า! แต่ก็อย่างที่เห็น พอทักไปก็โดนบล็อกเลย😓 เงินก็เสียมะขามก็อดกิน เศร้า',
	'ธนาคารไทยพาณิชย์', '0000000000', 'ผู้ขาย จากโพสต์', 'ขายมะขาม ส่งฟรีกรุงเทพ', 'facebook', '2025-04-30 16:16:16', 1000002, '/uploads/post_example_p1.jpg', 
    '/uploads/chat_info_p1.jpg', '/uploads/slip_example_p1.jpg', '/uploads/chat_example_p1.jpg'
);

insert into tags values
	('pets', 1),
    ('ไม่ตรงปก', 1),
    ('ของสัตว์เลี้ยง', 1),
    ('เติมเกม', 2),
    ('game', 2),
    ('เกม', 2),
    ('เกม', 3),
    ('มือสอง', 3),
    ('อาหารสัตว์', 4),
    ('สัตว์เลี้ยง', 4),
    ('pets', 4),
    ('food', 4),
    ('ไม่ส่งของ', 4),
    ('food', 5),
    ('ผลไม้', 5),
    ('ไม่ส่งของ', 5);

insert into Likes values
	(1, 1000002, 'like'),
    (3, 1000002, 'unlike');

insert into Follow values
	(1, 1000002, '2025-04-08 20:20:20'),
    (1, 1000004, '2025-04-09 20:20:20'),
    (3, 1000001, '2025-04-10 20:16:10'),
    (4, 1000002, '2025-03-10 20:20:20'),
    (5, 1000004, '2025-04-30 20:20:20');