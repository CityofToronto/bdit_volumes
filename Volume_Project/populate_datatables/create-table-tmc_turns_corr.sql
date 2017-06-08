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
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'n_cars_r', 1146976, 12334937,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'n_cars_t', 1146976, 7929920,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'n_cars_l', 1146976, 1147026,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'n_other', 1146976, 12334937,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 's_cars_r', 7929920, 1147026,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 's_cars_t', 7929920, 1146976,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'e_cars_r', 12334940, 1146976,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'w_cars_r', 30082883, 7929920,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'w_cars_t', 30082883, 1147026,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4161, 'w_cars_l', 30082974, 1146976,'EB','NB');

-- ARTERY CODE 4240: LAKESHORE AND LOWER JARVIS
-- Can't differentiate W-leg exit (1146303, 12341012 or 12341011), W-leg enter (20110785 or 30073994) or E-leg exit (12341013 or 8351267)
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'n_cars_r', 1146215, NULL,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'n_cars_t', 1146215, 8351261,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'n_cars_l', 1146215, NULL,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 's_cars_r', 8351261, NULL,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 's_cars_t', 8351261, 1146215,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 's_cars_l', 8351261, NULL,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'e_cars_r', 1146214, 1146215,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'e_cars_t', 1146214, NULL,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'e_cars_l', 1146214, 8351261,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'w_cars_r', NULL, 8351261,'EB','SB');
--INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
--VALUES (4240, 'w_cars_t', , ,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4240, 'w_cars_l', NULL, 1146215,'EB','NB');

-- ARTERY CODE 4418: CLAREMORE AND CLIFFSIDE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'n_cars_r', 30078799, 2893902,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'n_cars_t', 30078799, 112554,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'n_cars_l', 30078799, 30076788,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 's_cars_r', 112554, 30076788,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 's_cars_t', 112554, 30078799,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 's_cars_l', 112554, 2893902,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'e_cars_r', 30076788, 30078799,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'e_cars_t', 30076788, 2893902,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'e_cars_l', 30076788, 112554,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'w_cars_r', 2893930, 112554,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'w_cars_t', 2893930, 30076788,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4418, 'w_cars_l', 2893930, 30078799,'EB','NB');

-- ARTERY CODE 4584: EGLINTON AND MARTIN GROVE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'n_cars_r', 7009490, 12377332,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'n_cars_t', 7009490, 30007947,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'n_cars_l', 7009490, 909674,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 's_cars_r', 30007947, 909674,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 's_cars_t', 30007947, 7009490,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 's_cars_l', 30007947, 12377332,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'e_cars_r', 909674, 7009490,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'e_cars_t', 909674, 12377332,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'e_cars_l', 909674, 30007947,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'w_cars_r', 12377329, 30007947,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'w_cars_t', 12377329, 909674,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4584, 'w_cars_l', 12377329, 7009490,'EB','NB');

-- ARTERY CODE 4739: DON MILLS AND VAN HORNE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'n_cars_r', 10906429, 437228,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'n_cars_t', 10906429, 437272,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'n_cars_l', 10906429, 437189,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 's_cars_r', 437253, 437189,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 's_cars_t', 437253, 10906429,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 's_cars_l', 437253, 437228,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'e_cars_r', 437189, 10906429,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'e_cars_t', 437189, 437228,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'e_cars_l', 437189, 437272,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'w_cars_r', 437228, 437272,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'w_cars_t', 437228, 437189,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (4739, 'w_cars_l', 437228, 10906429,'EB','NB');

-- ARTERY CODE 5187: LAKESHORE AND LOWER SHERBOURNE
-- unable to isolate E leg between Lakeshore (20102845) and Gardiner Ramp (20102841)
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'n_cars_r', 1146052, 30087988,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'n_cars_t', 1146052, 30087997,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'n_cars_l', 1146052, 1146085,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 's_cars_r', 30087997, 1146085,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 's_cars_t', 30087997, 1146052,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 's_cars_l', 30087997, 30087988,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'e_cars_r', NULL, 1146052,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'e_cars_t', NULL, 30087988,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'e_cars_l', NULL, 30087997,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'w_cars_r', 1146181, 30087997,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'w_cars_t', 1146181, 1146085,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5187, 'w_cars_l', 1146181, 1146052,'EB','NB');

-- ARTERY CODE 5206: GOVERNMENT AND THE KINGSWAY
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'n_cars_r', 910667, 30017792,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'n_cars_t', 910667, 10663992,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'n_cars_l', 910667, 10663903,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 's_cars_r', 10663992, 10663903,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 's_cars_t', 10663992, 30017819,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 's_cars_l', 10663992, 30017792,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'e_cars_r', 10663903, 30017819,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'e_cars_t', 10663903, 30017792,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5206, 'e_cars_l', 10663903, 10663992,'WB','SB');

-- ARTERY CODE 5261: HIGHWAY 427 W TCS AND SHERWAY GARDENS
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'n_cars_r', 20061130, 30073850,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'n_cars_t', 20061130, 14257759,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'n_cars_l', 20061130, 913842,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 's_cars_r', 14257759, 913842,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 's_cars_t', 14257759, 20061120,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 's_cars_l', 14257759, 30073850,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'e_cars_r', 913842, 20061120,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'e_cars_t', 913842, 30073850,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'e_cars_l', 913842, 14257759,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'w_cars_r', 30073850, 14257759,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'w_cars_t', 30073850, 913842,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5261, 'w_cars_l', 30073850, 20061120,'EB','NB');

-- ARTERY CODE 5282: DUNDAS AND HIGHWAY 427 W TCS
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'n_cars_r', 913130, 913150,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'n_cars_l', 913100, 913098,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'e_cars_r', 913066, 913068,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'e_cars_t', 913066, 913098,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'w_cars_r', 913150, 913134,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5282, 'w_cars_t', 913150, 913129,'EB','EB');

-- ARTERY CODE 5331: BURNHAMTHORPE AND THE EAST MALL
-- need to fix W leg movements for ramp adjustments
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'n_cars_r', 911526, 911550,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'n_cars_t', 911526, 13969707,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'n_cars_l', 911526, 911525,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 's_cars_r', 13969707, 911525,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 's_cars_t', 13969707, 911526,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 's_cars_l', 13969707, 911550,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'e_cars_r', 911525, 911526,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'e_cars_t', 911525, 911550,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'e_cars_l', 911525, 13969707,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'w_cars_r', 911550, 13969707,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'w_cars_t', 911550, 911525,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5331, 'w_cars_l', 911550, 911526,'EB','NB');

-- ARTERY CODE 5492: SHEPPARD AND 404 N SHEPPARD
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'n_cars_r', 438116, 438117,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'n_cars_t', 438116, 20233508,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'n_cars_l', 438116, 30013029,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 's_cars_r', 20233508, 30013029,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 's_cars_t', 20233508, 438115,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 's_cars_l', 20233508, 438117,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'e_cars_r', 30013029, 438115,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'e_cars_t', 30013029, 438117,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'e_cars_l', 30013029, 20233508,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'w_cars_r', 438117, 20233508,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'w_cars_t', 438117, 30013029,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5492, 'w_cars_l', 438117, 438115,'EB','NB');

-- ARTERY CODE 5547: FINCH AND HIGHWAY 27
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'n_cars_r', 907198, 907227,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'n_cars_t', 907198, 907390,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'n_cars_l', 907198, 907189,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 's_cars_r', 907387, 907189,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 's_cars_t', 907387, 907190,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 's_cars_l', 907387, 907227,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'e_cars_r', 907189, 907190,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'e_cars_t', 907189, 907227,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'e_cars_l', 907189, 907390,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'w_cars_r', 907227, 907390,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'w_cars_t', 907227, 907189,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5547, 'w_cars_l', 907227, 907190,'EB','NB');

-- ARTERY CODE 5583: DON ROADWAY AND LAKESHORE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'n_cars_r', 20037413, 1145202,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'n_cars_t', 20037413, 1145325,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'n_cars_l', 20037413, 30021753,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 's_cars_r', 1145325, 30021753,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 's_cars_t', 1145325, 1145179,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 's_cars_l', 1145325, 1145202,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'e_cars_r', 30021753, 1145179,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'e_cars_t', 30021753, 1145202,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'e_cars_l', 30021753, 1145325,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'w_cars_r', 1145202, 1145325,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'w_cars_t', 1145202, 30021753,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5583, 'w_cars_l', 1145202, 1145179,'EB','NB');

-- ARTERY CODE 5678: RAMP W R ALLEN N/B OFF AND YORKDALE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5678, 's_cars_r', 444459, 30061209,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5678, 's_cars_l', 444459, 20080557,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5678, 'w_cars_t', 444252, 30061209,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5678, 'w_cars_l', 444252, 20080557,'EB','NB');

-- ARTERY CODE 5752: DON MILLS AND ESTERBROOKE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'n_cars_r', 437854, 9962920,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'n_cars_t', 437854, 438011,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'n_cars_l', 437854, 437852,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 's_cars_r', 438011, 437852,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 's_cars_t', 438011, 4975185,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 's_cars_l', 438011, 9962920,'NB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'e_cars_r', 437852, 4975185,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'e_cars_t', 437852, 9962920,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'e_cars_l', 437852, 438011,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'w_cars_r', 9962920, 438011,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'w_cars_t', 9962920, 437852,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5752, 'w_cars_l', 9962920, 4975185,'EB','NB');

-- ARTERY CODE 5760: ISLINGTON AND HIGHWAY 401 S TCS
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'n_cars_r', 908115, 20149479,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'n_cars_t', 908115, 20149476,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'n_cars_l', 908115, 908113,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 's_cars_r', 20149475, 30081655,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 's_cars_t', 20149475, 908115,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'e_cars_r', 908114, 908115,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'e_cars_t', 908114, 20149479,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'e_cars_l', 908114, 20149476,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'w_cars_r', 20149479, 20149476,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'w_cars_t', 20149479, 908113,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (5760, 'w_cars_l', 20149479, 908115,'EB','NB');

-- ARTERY CODE 6066: TRANSIT AND W R ALLEN
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'n_cars_r', 442309, 12382738,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'n_cars_t', 442309, 20164356,'SB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 's_cars_t', 20164343, 442309,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'e_cars_r', 20164406, 442309,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'e_cars_t', 20164406, 12382738,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'e_cars_l', 20164397, 20164356,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (6066, 'w_cars_l', 12382738, 442309,'EB','NB');

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

-- ARTERY CODE 11120: DUNDAS AND COLLEGE
-- doesn't include volumes from St. Helens currently
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'n_cars_r', 14017912, 1145519,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'n_cars_l', 14017912, 1145532,'SB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'e_cars_r', 1145532, 14017912,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'e_cars_t', 1145532, 1145519,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'w_cars_t', 1145519, 1145532,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (11120, 'w_cars_l', 1145519, 14017912,'EB','NB');

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

-- ARTERY CODE 12441: LONSDALE AND ORIOLE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 's_cars_r', 7262454, 7257434,'NB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 's_cars_t', 7262454, 20101792,'NB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 'e_cars_t', 20101792, 7254155,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 'e_cars_l', 20101792, 7262454,'WB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 'w_cars_r', 7254155, 20101792,'EB','SB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 'w_cars_t', 7254155, 7257434,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (12441, 'w_cars_l', 7254155, 20101792,'EB','NB');

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

-- ARTERY CODE 26436: ALLEN NB
-- appears to be missing a turn movement

-- ARTERY CODE 26437: ALLEN SB TO 401
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (26437, 'n_cars_r', 443403, 443740,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (26437, 'n_cars_l', 443403, 443558,'SB','SB');


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

-- ARTERY CODE 33929: ALLEN SB AND LAWRENCE
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (33929, 'n_cars_r', 444987, 445300,'SB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (33929, 'n_cars_t', 444987, 445326,'SB','SB');

-- ARTERY CODE 35068: LORD SEATON AND 401
-- didn't include S leg-related turns due to missing TCL link
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (35068, 'e_cars_r', 440858, 440859,'WB','NB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (35068, 'e_cars_t', 440858, 440869,'WB','WB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (35068, 'w_cars_t', 440954, 440929,'EB','EB');
INSERT INTO prj_volume.tmc_turns_corr(arterycode, movement, tcl_from_segment, tcl_to_segment, from_dir, to_dir)
VALUES (35068, 'w_cars_l', 440954, 440930,'EB','NB');

-- REMOVE ENTRIES FROM tmc_turns
DELETE FROM prj_volume.tmc_turns
WHERE arterycode IN (SELECT DISTINCT arterycode FROM prj_volume.tmc_turns_corr);

--UPDATE tmc_turns
INSERT INTO prj_volume.tmc_turns
SELECT * FROM prj_volume.tmc_turns_corr

-- ARTERY CODE 5206: GOVERNMENT AND THE KINGSWAY
-- NB/SB are separated on north leg
UPDATE prj_volume.tmc_turns
SET tcl_from_segment = 10663992, tcl_to_segment = 30017819
WHERE arterycode = 5206 AND movement LIKE 's%t';

UPDATE prj_volume.tmc_turns
SET tcl_from_segment = 10663903, tcl_to_segment = 30017819
WHERE arterycode = 5206 AND movement LIKE 'e%r';

-- ARTERY CODE 5678: Allen AND YORKDALE
-- West leg separated.  No north leg.
DELETE FROM prj_volume.tmc_turns
WHERE arterycode = 5678 AND movement LIKE 'e%';

DELETE FROM prj_volume.tmc_turns
WHERE arterycode = 5678 AND movement LIKE 'n%';

DELETE FROM prj_volume.tmc_turns
WHERE arterycode = 5678 AND (movement LIKE 's%t' OR movement LIKE 'w%l' OR movement LIKE 'w%r');

UPDATE prj_volume.tmc_turns
SET tcl_from_segment = 444459, tcl_to_segment = 20080557
WHERE arterycode = 5678 AND movement LIKE 's%l';
