TRUNCATE traffic.arterydata;
INSERT INTO traffic.arterydata SELECT * FROM traffic_new.arterydata;

TRUNCATE traffic.cnt_det;
INSERT INTO traffic.cnt_det SELECT * FROM traffic_new.cnt_det;

TRUNCATE traffic.countinfo;
INSERT INTO traffic.countinfo SELECT * FROM traffic_new.countinfo;

TRUNCATE traffic.countinfomics;
INSERT INTO traffic.countinfomics SELECT * FROM traffic_new.countinfomics;

TRUNCATE traffic.det;
INSERT INTO traffic.det SELECT * FROM traffic_new.det;

TRUNCATE traffic.node;
INSERT INTO traffic.node SELECT * FROM traffic_new.node;