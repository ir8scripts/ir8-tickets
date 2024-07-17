create table ir8_ticket
(
    id         int auto_increment
        primary key,
    category   varchar(255)                          null,
    title      varchar(255)                          null,
    message    longtext                              null,
    name       varchar(255)                          null,
    identifier varchar(255)                          null,
    position   varchar(1000)                         null,
    status     varchar(50)                           null,
    date       timestamp default current_timestamp() not null,
    updated    timestamp default current_timestamp() not null on update current_timestamp()
);

create table ir8_ticket_message
(
    id         int auto_increment
        primary key,
    ticket_id  int                                   null,
    message    longtext                              null,
    name       varchar(255)                          null,
    identifier varchar(255)                          null,
    date       timestamp default current_timestamp() not null
);

