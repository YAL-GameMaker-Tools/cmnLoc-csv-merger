@:native("CSV")
extern class CSV {
	static function parse(snip:String, ?dialect:CSVDialect):CSVData;
	static function serialize(table:CSVData, ?dialect:CSVDialect):String;
}
typedef CSVData = Array<Array<String>>;
typedef CSVDialect = {
	csvddfVersion:Float,
	delimiter:String,
	doubleQuote:Bool,
	lineTerminator:String,
	quoteChar:String,
	skipInitialSpace:Bool,
	header:Bool,
	commentChar:String
};