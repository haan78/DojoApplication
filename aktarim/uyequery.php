<?php

function uyequery ():array {
    return array (
      0 => 
      array (
        '$addFields' => 
        array (
          'keikoaylar' => 
          array (
            '$setUnion' => 
            array (
              '$map' => 
              array (
                'input' => '$keikolar',
                'as' => 'ktar',
                'in' => 
                array (
                  '$dateToString' => 
                  array (
                    'format' => '%Y-%m',
                    'date' => '$$ktar',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      1 => 
      array (
        '$lookup' => 
        array (
          'from' => 'gelirgider',
          'localField' => '_id',
          'foreignField' => 'uye_id',
          'as' => 'aidatlar',
          'pipeline' => 
          array (
            0 => 
            array (
              '$match' => 
              array (
                '$and' => 
                array (
                  0 => 
                  array (
                    '$expr' => 
                    array (
                      '$eq' => 
                      array (
                        0 => '$tur',
                        1 => 'GELIR',
                      ),
                    ),
                  ),
                  1 => 
                  array (
                    '$expr' => 
                    array (
                      '$gt' => 
                      array (
                        0 => '$ay',
                        1 => 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            1 => 
            array (
              '$project' => 
              array (
                '_id' => 0,
                'yilay' => 
                array (
                  '$dateToString' => 
                  array (
                    'format' => '%Y-%m',
                    'date' => 
                    array (
                      '$dateFromParts' => 
                      array (
                        'year' => '$yil',
                        'month' => '$ay',
                        'day' => 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            2 => 
            array (
              '$group' => 
              array (
                '_id' => '$yilay',
              ),
            ),
          ),
        ),
      ),
      2 => 
      array (
        '$addFields' => 
        array (
          'aidatlar' => '$aidatlar._id',
        ),
      ),
      3 => 
      array (
        '$addFields' => 
        array (
          'aidateksigi' => 
          array (
            '$setDifference' => 
            array (
              0 => '$keikoaylar',
              1 => '$aidatlar',
            ),
          ),
        ),
      ),
      4 => 
      array (
        '$lookup' => 
        array (
          'from' => 'gelirgider',
          'localField' => '_id',
          'foreignField' => 'uye_id',
          'as' => 'gelirgider',
        ),
      ),
    );
}