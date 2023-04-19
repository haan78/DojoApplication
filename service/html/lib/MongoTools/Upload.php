<?php

namespace MongoTools {

    use DateTime;
    use Exception;
    use \MongoDB\BSON\ObjectId;
    use \MongoDB\GridFS\Bucket;
    use \MongoDB\BSON\UTCDateTime;


    class Upload
    {


        public static int $maxUploadCount = 10;
        public static float $maxTotalUpSizeMb = 8; //8mb
        public static float $maxUpSizeMb = 8;
        public static array $types = ["image/png", "image/jpeg", "image/gif", "application/pdf", "image/svg+xml", "image/webp", "image/tiff"];

        private static function controlFiles(): void
        {

            if (!empty($_FILES)) {
                if ( count( array_keys($_FILES) ) > static::$maxUploadCount ) {
                    throw new Exception("Maximum upload limit is ".static::$maxUploadCount." files");
                }
                $total = 0;
                foreach ($_FILES as $f) {
                    $size = intval($f["size"]);
                    $type = strtolower($f["type"]);
                    $name = $f["name"];
                    if ( !empty(self::$types) && !in_array( $type,self::$types ) ) {
                        throw new Exception("MIME type $type of the file $name is not allowed ");
                    } elseif ( $size > self::$maxUpSizeMb * 1024 * 1024 ) {
                        throw new Exception("Maximum upload size of the file $name is ".self::$maxUpSizeMb."Mb");
                    }
                    $total += $size;
                }
                if ($total > (static::$maxTotalUpSizeMb * 1024 * 1024) ) {
                    throw new Exception("Maximum upload size is ".static::$maxTotalUpSizeMb."Mb");
                }                
            } else {
                throw new Exception("There is no upload file");
            }
        }

        private static function toMongo(array $f, Bucket $bucket,string $infotext, int $ind): string
        {
            $data = [
                "upload_time" => new UTCDateTime(),
                "upload_file_type" => $f["type"],
                "upload_file_name" => $f["name"],
                "upload_file_info_text" => $infotext,
                "upload_file_index" => $ind
            ];
            $stream = fopen($f["tmp_name"], 'r');
            $_id = $bucket->uploadFromStream($f["name"], $stream, ["metadata" => $data]);
            return $_id->__toString();
        }

        public static function save(Bucket $bucket, string $infotext = ""): string
        {
            static::controlFiles();

            $list = [];
            $ind = 0;
            foreach ($_FILES as $k => $f) {
                array_push($list, self::toMongo($f, $bucket,$infotext,$ind));
                $ind++;
            }
            return implode(",", $list);
        }

        public static function delete(Bucket $bucket, string $_id)
        {
            $id = new ObjectId($_id);
            $bucket->delete($id);
        }

        public static function download(Bucket $bucket, string $_id)
        {
            $id = new ObjectId($_id);

            $result = $bucket->findOne(["_id" => $id]);
            $destination = fopen('php://temp', 'w+b');
            $bucket->downloadToStream($id, $destination);
            header("Content-Type: " . $result->metadata->file_type);
            echo stream_get_contents($destination, -1, 0);
        }

        public static function get(Bucket $bucket, string $_id, &$file_type)
        {
            $id = new ObjectId($_id);
            $result = $bucket->findOne(["_id" => $id]);
            $destination = fopen('php://temp', 'w+b');
            $bucket->downloadToStream($id, $destination);
            $file_type = $result->metadata->file_type;
            return stream_get_contents($destination, -1, 0);
        }
    }
}
