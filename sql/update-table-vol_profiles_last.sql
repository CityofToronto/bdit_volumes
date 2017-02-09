UPDATE prj_volume.vol_profiles_last
SET time_bin = time_bin - interval '15 minutes'
WHERE arterycode IN (SELECT arterycode FROM prj_volume.vol_profiles_last WHERE time_bin IN ('23:59:59', '23:59:00'));

UPDATE prj_volume.vol_profiles_last
SET time_bin = time_bin + interval '1 second'
WHERE time_bin = '23:44:59';

UPDATE prj_volume.vol_profiles_last
SET time_bin = time_bin + interval '1 minute'
WHERE time_bin = '23:44:00';