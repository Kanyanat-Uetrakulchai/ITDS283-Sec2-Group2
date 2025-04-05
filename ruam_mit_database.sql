create database if not exists mobile_s2_gr2;
use mobile_s2_gr2;
-- drop database mobile_s2_gr2;

create table if not exists Users (
	uid				int				not null	auto_increment,
    username		varchar(20)		not null,
    password		varchar(20)		not null,
    profile			blob,
    joinDate		date			not null,
    constraint		PK_users		primary key (uid)
);

create table if not exists Post (
	postId 			int 			not null	auto_increment,
    caption 		varchar(100),
    detail 			varchar(1000),
    mij_bank		varchar(20),
    mij_bankno		varchar(15),
    mij_name		varchar(50),
    mij_acc			varchar(50),
    mij_plat		varchar(20),
    p_timestamp		datetime,
    uid				int,
    constraint 		PK_post 		primary key (postId),
    constraint		FK_post			foreign key (uid) references Users(uid)
);

create table if not exists Tags(
	tag				varchar(50)		not null,
    postId			int				not null,
    constraint 		PK_tags 		primary key (tag,postId),
    constraint 		FK_tags 		foreign key (postId) references Post(postId)
);

-- Post's Pictures 
create table if not exists P_Pics (
	postId			int,
    picNo			int,
    pic				blob,
    constraint		PK_p_pics 		primary key (postId, picNo),
    constraint		FK_p_pics		foreign key (postId) references Post(postId)
);

create table if not exists Likes(
	postId			int,
    uid				int,
    status			boolean,
    constraint		PK_likes 		primary key (postId, uid),
    constraint		FK_likes_p		foreign key (postId) references Post(postId),
    constraint		FK_likes_u		foreign key (uid) references Users(uid)
);

create table Comments(
	commId			int				not null	auto_increment,
    postId			int,
    uid				int,
    message			varchar(100),
    c_timestamp		datetime,
    constraint 		PK_comm 		primary key (commid),
    constraint		FK_comm_p		foreign key (postId) references Post(postId),
    constraint		FK_comm_u		foreign key (uid) references Users(uid)
);

-- Comment's Pictures 
create table if not exists C_Pics (
	commId			int,
    picNo			int,
    pic				blob,
    constraint		PK_c_pics 		primary key (commId, picNo),
    constraint		FK_c_pics		foreign key (commId) references Comments(commId)
);

-- first post has to specify to initiate autoincrement
insert into Users values
	(1000001, 'admin', 'p@ssw0rd', null, '2025-03-01');

insert into Post (caption, detail, mij_bank, mij_bankno, mij_name, mij_acc, mij_plat, p_timestamp, uid) values(
	'test post no 1', 'asddhkflffvvmvnvkccpdkfmrbdvchxjldlcc;sjsnxkcc',
	'กรุงเทพ', '123456789012', 'มิจ เองจ้า', 'the fake shop', 'facebook', '2025-04-04 17:17:17', 1000001
);

insert into Users values
	(null, 'สมาชิก A', 'p@ssw0rd123', null, '2025-03-03');
    
insert into Post values(
	null, 'test post no 2', 'poiufdsdcvbnmklkjhgfdcvbnm,lkjhgfvbnm,lkjhgf',
    'กรุงศรี', '3698521470', 'นี่ ก็มิจจ้า', 'phish shop', 'instagram', '2025-04-08 20:20:20', 1000002
);

insert into tags values
	('pets', 1),
    ('food', 1),
    ('tag', 1),
    ('pre-order', 2),
    ('tag', 2),
    ('fandom', 2);

insert into Likes values
	(1, 1000002, true);

select * from Users;

-- fetch posts by tag
select p.* from post p inner join tags t on p.postId = t.postId where t.tag = 'tag';

-- fetch tag of post
select t.tag from post p inner join tags t on p.postId = t.postId where p.postId = 1;

-- fetch number of post by tag
select count(p.postId) from post p inner join tags t on p.postId = t.postId where t.tag = 'tag';