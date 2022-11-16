CREATE TABLE IF NOT EXISTS `angelicxs_billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) DEFAULT NULL,
  `invoice` int(11) NOT NULL DEFAULT 0,
  `society` varchar(60) DEFAULT NULL,
  `sender` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=289 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;