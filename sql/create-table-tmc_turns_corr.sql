DROP TABLE IF EXISTS prj_volume.tmc_turns_corr;

CREATE TABLE prj_volume.tmc_turns_corr (
	turn_id serial NOT NULL,
	arterycode int not null,
	movement text,
	tcl_from_segment int,
	tcl_to_segment int,
	from_dir text,
	to_dir text
	);

-- ARTERY CODE 3928: BRITISH COLUMBIA AND LAKESHORE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'n_cars_r', 1147537, 5999366,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'n_cars_t', 1147537, 12334628,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 's_cars_t', 1147544, 1234628,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 's_cars_l', 1147544, 5999366,'EB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'e_cars_r', 1147551, 1147537,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'e_cars_t', 1147551, 5999366,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'e_cars_l', 1147551, 12334628,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'w_cars_t', 1147544, 1147552,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (3928, 'w_cars_l', 1147544, 1147537,'EB','EB');

-- ARTERY CODE 4079: CANARCTIC AND KEELE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'n_cars_r', 14065128, 20119999,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'n_cars_t', 14065128, 14064697,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'n_cars_l', 14065128, 8594542,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 's_cars_r', 14064697, 8594542,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 's_cars_t', 14064697, 14065128,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 's_cars_l', 14064697, 20119999,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'e_cars_r', 8594542, 14065128,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'e_cars_t', 8594542, 20119999,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'e_cars_l', 8594542, 14064697,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'w_cars_r', 20149167, 14064697,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'w_cars_t', 20149167, 8594542,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4079, 'w_cars_l', 20149167, 14065128,'EB','NB');

-- ARTERY CODE 4161: LAKESHORE AND LOWER SPADINA

-- ARTERY CODE 4240: LAKESHORE AND LOWER JARVIS

-- ARTERY CODE 4418: CLAREMORE AND CLIFFSIDE

-- ARTERY CODE 4584: EGLINTON AND MARTIN GROVE

-- ARTERY CODE 4739: DON MILLS AND VAN HORNE

-- ARTERY CODE 5187: LAKESHORE AND LOWER SHERBOURNE

-- ARTERY CODE 5206: GOVERNMENT AND THE KINGSWAY

-- ARTERY CODE 5261: HIGHWAY 427 W TCS AND SHERWAY GARDENS

-- ARTERY CODE 5282: DUNDAS AND HIGHWAY 427 W TCS

-- ARTERY CODE 5331: BURNHAMTHORPE AND THE EAST MALL

-- ARTERY CODE 5492: SHEPPARD AND 404 N SHEPPARD

-- ARTERY CODE 5547: FINCH AND HIGHWAY 27

-- ARTERY CODE 5583: DON ROADWAY AND LAKESHORE

-- ARTERY CODE 5678: RAMP W R ALLEN N/B OFF AND YORKDALE

-- ARTERY CODE 5752: DON MILLS AND ESTERBROOKE

-- ARTERY CODE 5760: ISLINGTON AND HIGHWAY 401 S TCS

-- ARTERY CODE 6066: TRANSIT AND W R ALLEN

-- ARTERY CODE 6465: BOULTBEE AND JONES
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'n_cars_r', 8896633, 8492575,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'n_cars_t', 8896633, 1141641,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'n_cars_l', 8896633, 10606418,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 's_cars_r', 1141641, 10606418,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 's_cars_t', 1141641, 8896633,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 's_cars_l', 1141641, 8492575,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'e_cars_r', 10606418, 8896633,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'e_cars_t', 10606418, 8492575,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'e_cars_l', 10606418, 1141641,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'w_cars_r', 8492575, 1141641,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'w_cars_t', 8492575, 10606418,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6465, 'w_cars_l', 8492575, 8896633,'EB','NB');

-- ARTERY CODE 11308: HIGHWAY 27 AND ROYALCREST
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 'n_cars_t', 20229259, 20229258,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 'n_cars_l', 20229259, 906636,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 's_cars_r', 906720, 906636,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 's_cars_t', 906720, 20113061,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 'e_cars_r', 906636, 20113061,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11308, 'e_cars_l', 906636, 20229258,'WB','SB');


-- ARTERY CODE 22644: DUNDAS AND JOPLING
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'n_cars_r', 912189, 10636395,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'n_cars_t', 912189, 20037499,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'n_cars_l', 912189, 912187,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 's_cars_r', 20037499, 912187,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 's_cars_t', 20037499, 912189,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 's_cars_l', 20037499, 10636395,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'e_cars_r', 10636387, 912189,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'e_cars_t', 10636387, 10636395,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'e_cars_l', 10636387, 20037499,'WB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'w_cars_r', 10636395, 20037499,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'w_cars_t', 10636395, 912187,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (22644, 'w_cars_l', 10636395, 912189,'EB','NB');

-- ARTERY CODE 32474: ALYWARD AND BEECHBOROUGH
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 's_cars_r', 7759, 7742,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 's_cars_t', 7759, 3202334,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 's_cars_l', 7759, 7753,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'e_cars_r', 7742, 3202334,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'e_cars_t', 7742, 7753,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'e_cars_l', 7742, 7759,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'w_cars_r', 7753, 7759,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'w_cars_t', 7753, 7742,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'w_cars_l', 7753, 3202334,'EB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'e_cars_other', 7742, 7865,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (32474, 'w_cars_other', 7753, 7865,'EB','SB');