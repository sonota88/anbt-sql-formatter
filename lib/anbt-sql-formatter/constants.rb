# -*- coding: utf-8 -*-

=begin rdoc
AnbtSqlFormatter: SQL整形ツール. SQL文を決められたルールに従い整形します。

フォーマットを実施するためには、入力されるSQLがSQL文として妥当であることが前提条件となります。

このクラスが準拠するSQL整形のルールについては、下記URLを参照ください。
http://homepage2.nifty.com/igat/igapyon/diary/2005/ig050613.html

このクラスには ANSI SQLの予約語一覧が蓄えられます。

@author IGA Tosiki
@author sonota
=end


class AnbtSql
  class Constants
    # ANSI SQL キーワード
    SQL_RESERVED_WORDS =
      [
       # ANSI SQL89
       "ALL", "AND", "ANY", "AS", "ASC", "AUTHORIZATION", "AVG", "BEGIN",
       "BETWEEN", "BY", "CHAR", "CHARACTER", "CHECK", "CLOSE", "COBOL",
       "COMMIT", "CONTINUE", "COUNT", "CREATE", "CURRENT", "CURSOR",
       "DEC", "DECIMAL", "DECLARE", "DEFAULT", "DELETE", "DESC",
       "DISTINCT", "DOUBLE", "END", "ESCAPE", "EXEC", "EXISTS", "FETCH",
       "FLOAT", "FOR", "FOREIGN", "FORTRAN", "FOUND", "FROM", "GO",
       "GOTO", "GRANT", "GROUP", "HAVING", "IN", "INDICATOR", "INSERT",
       "INT", "INTEGER", "INTO", "IS", "KEY", "LANGUAGE", "LIKE", "MAX",
       "MIN", "MODULE", "NOT", "NULL", "NUMERIC", "OF", "ON", "OPEN",
       "OPTION", "OR", "ORDER", "PASCAL", "PLI", "PRECISION", "PRIMARY",
       "PRIVILEGES", "PROCEDURE", "PUBLIC", "REAL", "REFERENCES",
       "ROLLBACK", "SCHEMA", "SECTION", "SELECT", "SET", "SMALLINT",
       "SOME", "SQL", "SQLCODE", "SQLERROR", "SUM", "TABLE", "TO",
       "UNION", "UNIQUE", "UPDATE", "USER", "VALUES", "VIEW",
       "WHENEVER", "WHERE", "WITH", "WORK",
       # ANSI SQL92
       "ABSOLUTE", "ACTION", "ADD", "ALLOCATE", "ALTER", "ARE",
       "ASSERTION", "AT", "BIT", "BIT_LENGTH", "BOTH", "CASCADE",
       "CASCADED", "CASE", "CAST", "CATALOG", "CHAR_LENGTH",
       "CHARACTER_LENGTH", "COALESCE", "COLLATE", "COLLATION", "COLUMN",
       "CONNECT", "CONNECTION", "CONSTRAINT", "CONSTRAINTS", "CONVERT",
       "CORRESPONDING", "CROSS", "CURRENT_DATE", "CURRENT_TIME",
       "CURRENT_TIMESTAMP", "CURRENT_USER", "DATE", "DAY", "DEALLOATE",
       "DEFERRABLE", "DEFERRED", "DESCRIBE", "DESCRIPTOR", "DIAGNOSTICS",
       "DISCONNECT", "DOMAIN", "DROP", "ELSE", "END-EXEC", "EXCEPT",
       "EXCEPTION", "EXECUTE", "EXTERNAL", "EXTRACT", "FALSE", "FIRST",
       "FULL", "GET", "GLOBAL", "HOUR", "IDENTITY", "IMMEDIATE",
       "INITIALLY", "INNER", "INPUT", "INSENSITIVE", "INTERSECT",
       "INTERVAL", "ISOLATION", "JOIN", "LAST", "LEADING", "LEFT",
       "LEVEL", "LOCAL", "LOWER", "MATCH", "MINUTE", "MONTH", "NAMES",
       "NATIONAL", "NATURAL", "NCHAR", "NEXT", "NO", "NULLIF",
       "OCTET_LENGTH", "ONLY", "OUTER", "OUTPUT", "OVERLAPS", "PAD",
       "PARTIAL", "POSITION", "PREPARE", "PRESERVE", "PRIOR", "READ",
       "RELATIVE", "RESTRICT", "REVOKE", "RIGHT", "ROWS", "SCROLL",
       "SECOND", "SESSION", "SESSION_USER", "SIZE", "SPACE", "SQLSTATE",
       "SUBSTRING", "SYSTEM_USER", "TEMPORARY", "THEN", "TIME",
       "TIMESTAMP", "TIMEZONE_HOUR", "TIMEZONE_MINUTE", "TRAILING",
       "TRANSACTION", "TRANSLATE", "TRANSLATION", "TRIM", "TRUE",
       "UNKNOWN", "UPPER", "USAGE", "USING", "VALUE", "VARCHAR",
       "VARYING", "WHEN", "WRITE", "YEAR", "ZONE",
       # ANSI SQL99
       "ADMIN", "AFTER", "AGGREGATE", "ALIAS", "ARRAY", "BEFORE",
       "BINARY", "BLOB", "BOOLEAN", "BREADTH", "CALL", "CLASS", "CLOB",
       "COMPLETION", "CONDITION", "CONSTRUCTOR", "CUBE", "CURRENT_PATH",
       "CURRENT_ROLE", "CYCLE", "DATA", "DEPTH", "DEREF", "DESTROY",
       "DESTRUCTOR", "DETERMINISTIC", "DICTIONARY", "DO", "DYNAMIC",
       "EACH", "ELSEIF", "EQUALS", "EVERY", "EXIT", "FREE", "FUNCTION",
       "GENERAL", "GROUPING", "HANDLER", "HOST", "IF", "IGNORE",
       "INITIALIZE", "INOUT", "ITERATE", "LARGE", "LATERAL", "LEAVE",
       "LESS", "LIMIT", "LIST", "LOCALTIME", "LOCALTIMESTAMP", "LOCATOR",
       "LONG", "LOOP", "MAP", "MODIFIES", "MODIFY", "NCLOB", "NEW",
       "NONE", "NUMBER", "OBJECT", "OFF", "OLD", "OPERATION",
       "ORDINALITY", "OUT", "PARAMETER", "PARAMETERS", "PATH", "POSTFIX",
       "PREFIX", "PREORDER", "RAW", "READS", "RECURSIVE", "REDO",
       # ANSI SQLではないのだが とても良く使われる構文
       "TRUNCATE" ]
  end
end
