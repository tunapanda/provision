<?php

return array(
  'connections' => array(
    'mongodb' => array(
		'driver'   => 'mongodb',
		'host'     => 'localhost',
		'port'     => 27017,
		'username' => '{{learninglocker__db_user}}',
		'password' => '{{learninglocker__db_pass}}',
		'database' => '{{learninglocker__active_db}}'
    )
  )
);
