CREATE TABLE boards (
    bno       number        primary key,
    btitle    varchar2(100) not null,
    bcontent  clob          not null,
    bwriter   varchar2(50)  not null,
    bdate     date default  sysdate,
    bfilename varchar2(50)  null,
    bfiledata blob          null
);    

CREATE TABLE accounts (
    ano varchar(20) primary key,
    owner varchar(20) not null,
    balance number not null
);

INSERT INTO accounts (ano, owner, balance)
values ('111-111-1111', '하여름', 1000000);

INSERT INTO accounts (ano, owner, balance)
values ('222-222-2222', '한겨울', 0);

CREATE SEQUENCE SEQ_BNO NOCACHE;

SELECT * FROM accounts;

CREATE TABLE users (
    userid       varchar2(50)   primary key,
    username     varchar2(50)   not null,
    userpassword varchar2(50)   not null,
    userage      number(3)      not null,
    useremail    varchar2(50)   not null
);    

SELECT * FROM users;

SELECT * FROM boards;