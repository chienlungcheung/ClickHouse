SET allow_experimental_data_skipping_indices = 1;

DROP TABLE IF EXISTS test.single_column_bloom_filter;

CREATE TABLE test.single_column_bloom_filter (u64 UInt64, i32 Int32, i64 UInt64, INDEX idx (i32) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY u64 SETTINGS index_granularity = 6;

INSERT INTO test.single_column_bloom_filter SELECT number AS u64, number AS i32, number AS i64 FROM system.numbers LIMIT 100;

SELECT COUNT() FROM test.single_column_bloom_filter WHERE i32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i32) = (1, 2) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i64) = (1, 1) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i64, (i64, i32)) = (1, (1, 1)) SETTINGS max_rows_to_read = 6;

SELECT COUNT() FROM test.single_column_bloom_filter WHERE i32 IN (1, 2) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i32) IN ((1, 2), (2, 3)) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i64) IN ((1, 1), (2, 2)) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i64, (i64, i32)) IN ((1, (1, 1)), (2, (2, 2))) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE i32 IN (SELECT arrayJoin([toInt32(1), toInt32(2)])) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i32) IN (SELECT arrayJoin([(toInt32(1), toInt32(2)), (toInt32(2), toInt32(3))])) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i64) IN (SELECT arrayJoin([(toInt32(1), toUInt64(1)), (toInt32(2), toUInt64(2))])) SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i64, (i64, i32)) IN (SELECT arrayJoin([(toUInt64(1), (toUInt64(1), toInt32(1))), (toUInt64(2), (toUInt64(2), toInt32(2)))])) SETTINGS max_rows_to_read = 6;
WITH (1, 2) AS liter_prepared_set SELECT COUNT() FROM test.single_column_bloom_filter WHERE i32 IN liter_prepared_set SETTINGS max_rows_to_read = 6;
WITH ((1, 2), (2, 3)) AS liter_prepared_set SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i32) IN liter_prepared_set SETTINGS max_rows_to_read = 6;
WITH ((1, 1), (2, 2)) AS liter_prepared_set SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i32, i64) IN liter_prepared_set SETTINGS max_rows_to_read = 6;
WITH ((1, (1, 1)), (2, (2, 2))) AS liter_prepared_set SELECT COUNT() FROM test.single_column_bloom_filter WHERE (i64, (i64, i32)) IN liter_prepared_set SETTINGS max_rows_to_read = 6;

DROP TABLE IF EXISTS test.single_column_bloom_filter;


DROP TABLE IF EXISTS test.bloom_filter_types_test;

CREATE TABLE test.bloom_filter_types_test (order_key   UInt64, i8 Int8, i16 Int16, i32 Int32, i64 Int64, u8 UInt8, u16 UInt16, u32 UInt32, u64 UInt64, f32 Float32, f64 Float64, date Date, date_time DateTime('Europe/Moscow'), str String, fixed_string FixedString(5), INDEX idx (i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, date, date_time, str, fixed_string) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY order_key SETTINGS index_granularity = 6;
INSERT INTO test.bloom_filter_types_test SELECT number AS order_key, toInt8(number) AS i8, toInt16(number) AS i16, toInt32(number) AS i32, toInt64(number) AS i64, toUInt8(number) AS u8, toUInt16(number) AS u16, toUInt32(number) AS u32, toUInt64(number) AS u64, toFloat32(number) AS f32, toFloat64(number) AS f64, toDate(number, 'Europe/Moscow') AS date, toDateTime(number, 'Europe/Moscow') AS date_time, toString(number) AS str, toFixedString(toString(number), 5) AS fixed_string FROM system.numbers LIMIT 100;

SELECT COUNT() FROM test.bloom_filter_types_test WHERE i8 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE i16 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE i32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE i64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE u8 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE u16 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE u32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE u64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE f32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE f64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE date = '1970-01-02' SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE date_time = toDateTime('1970-01-01 03:00:01', 'Europe/Moscow') SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE str = '1' SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_types_test WHERE fixed_string = toFixedString('1', 5) SETTINGS max_rows_to_read = 12;

SELECT COUNT() FROM test.bloom_filter_types_test WHERE str IN ( SELECT str FROM test.bloom_filter_types_test);

DROP TABLE IF EXISTS test.bloom_filter_types_test;

DROP TABLE IF EXISTS test.bloom_filter_array_types_test;

CREATE TABLE test.bloom_filter_array_types_test (order_key   Array(UInt64), i8 Array(Int8), i16 Array(Int16), i32 Array(Int32), i64 Array(Int64), u8 Array(UInt8), u16 Array(UInt16), u32 Array(UInt32), u64 Array(UInt64), f32 Array(Float32), f64 Array(Float64), date Array(Date), date_time Array(DateTime('Europe/Moscow')), str Array(String), fixed_string Array(FixedString(5)), INDEX idx (i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, date, date_time, str, fixed_string) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY order_key SETTINGS index_granularity = 6;
INSERT INTO test.bloom_filter_array_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers LIMIT 15);
INSERT INTO test.bloom_filter_array_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers WHERE number >= 5 LIMIT 15);
INSERT INTO test.bloom_filter_array_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers WHERE number >= 10 LIMIT 15);

SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i8, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i16, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i32, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i64, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u8, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u16, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u32, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u64, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f32, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f64, 1);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date, toDate('1970-01-02'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:01', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(str, '1');
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(fixed_string, toFixedString('1', 5));

SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i8, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i16, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i32, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i64, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u8, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u16, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u32, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u64, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f32, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f64, 5);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date, toDate('1970-01-06'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:05', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(str, '5');
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(fixed_string, toFixedString('5', 5));

SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i8, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i16, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i32, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(i64, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u8, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u16, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u32, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(u64, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f32, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(f64, 10);
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date, toDate('1970-01-11'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:10', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(str, '10');
SELECT COUNT() FROM test.bloom_filter_array_types_test WHERE has(fixed_string, toFixedString('10', 5));

DROP TABLE IF EXISTS test.bloom_filter_array_types_test;

DROP TABLE IF EXISTS test.bloom_filter_null_types_test;

CREATE TABLE test.bloom_filter_null_types_test (order_key UInt64, i8 Nullable(Int8), i16 Nullable(Int16), i32 Nullable(Int32), i64 Nullable(Int64), u8 Nullable(UInt8), u16 Nullable(UInt16), u32 Nullable(UInt32), u64 Nullable(UInt64), f32 Nullable(Float32), f64 Nullable(Float64), date Nullable(Date), date_time Nullable(DateTime('Europe/Moscow')), str Nullable(String), fixed_string Nullable(FixedString(5)), INDEX idx (i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, date, date_time, str, fixed_string) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY order_key SETTINGS index_granularity = 6;
INSERT INTO test.bloom_filter_null_types_test SELECT number AS order_key, toInt8(number) AS i8, toInt16(number) AS i16, toInt32(number) AS i32, toInt64(number) AS i64, toUInt8(number) AS u8, toUInt16(number) AS u16, toUInt32(number) AS u32, toUInt64(number) AS u64, toFloat32(number) AS f32, toFloat64(number) AS f64, toDate(number, 'Europe/Moscow') AS date, toDateTime(number, 'Europe/Moscow') AS date_time, toString(number) AS str, toFixedString(toString(number), 5) AS fixed_string FROM system.numbers LIMIT 100;
INSERT INTO test.bloom_filter_null_types_test SELECT 0 AS order_key, NULL AS i8, NULL AS i16, NULL AS i32, NULL AS i64, NULL AS u8, NULL AS u16, NULL AS u32, NULL AS u64, NULL AS f32, NULL AS f64, NULL AS date, NULL AS date_time, NULL AS str, NULL AS fixed_string;

SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE i8 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE i16 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE i32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE i64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE u8 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE u16 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE u32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE u64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE f32 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE f64 = 1 SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE date = '1970-01-02' SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE date_time = toDateTime('1970-01-01 03:00:01', 'Europe/Moscow') SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE str = '1' SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE fixed_string = toFixedString('1', 5) SETTINGS max_rows_to_read = 12;

SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(i8);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(i16);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(i32);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(i64);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(u8);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(u16);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(u32);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(u64);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(f32);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(f64);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(date);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(date_time);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(str);
SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE isNull(fixed_string);

SELECT COUNT() FROM test.bloom_filter_null_types_test WHERE str IN ( SELECT str FROM test.bloom_filter_null_types_test);

DROP TABLE IF EXISTS test.bloom_filter_null_types_test;

DROP TABLE IF EXISTS test.bloom_filter_lc_null_types_test;

CREATE TABLE test.bloom_filter_lc_null_types_test (order_key UInt64, str LowCardinality(Nullable(String)), fixed_string LowCardinality(Nullable(FixedString(5))), INDEX idx (str, fixed_string) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY order_key SETTINGS index_granularity = 6;
INSERT INTO test.bloom_filter_lc_null_types_test SELECT number AS order_key, toString(number) AS str, toFixedString(toString(number), 5) AS fixed_string FROM system.numbers LIMIT 100;
INSERT INTO test.bloom_filter_lc_null_types_test SELECT 0 AS order_key, NULL AS str, NULL AS fixed_string;

SELECT COUNT() FROM test.bloom_filter_lc_null_types_test WHERE str = '1' SETTINGS max_rows_to_read = 6;
SELECT COUNT() FROM test.bloom_filter_lc_null_types_test WHERE fixed_string = toFixedString('1', 5) SETTINGS max_rows_to_read = 12;

SELECT COUNT() FROM test.bloom_filter_lc_null_types_test WHERE isNull(str);
SELECT COUNT() FROM test.bloom_filter_lc_null_types_test WHERE isNull(fixed_string);

SELECT COUNT() FROM test.bloom_filter_lc_null_types_test WHERE str IN ( SELECT str FROM test.bloom_filter_lc_null_types_test);

DROP TABLE IF EXISTS test.bloom_filter_lc_null_types_test;

DROP TABLE IF EXISTS test.bloom_filter_array_lc_null_types_test;

CREATE TABLE test.bloom_filter_array_lc_null_types_test (order_key   Array(LowCardinality(Nullable((UInt64)))), i8 Array(LowCardinality(Nullable((Int8)))), i16 Array(LowCardinality(Nullable((Int16)))), i32 Array(LowCardinality(Nullable((Int32)))), i64 Array(LowCardinality(Nullable((Int64)))), u8 Array(LowCardinality(Nullable((UInt8)))), u16 Array(LowCardinality(Nullable((UInt16)))), u32 Array(LowCardinality(Nullable((UInt32)))), u64 Array(LowCardinality(Nullable((UInt64)))), f32 Array(LowCardinality(Nullable((Float32)))), f64 Array(LowCardinality(Nullable((Float64)))), date Array(LowCardinality(Nullable((Date)))), date_time Array(LowCardinality(Nullable(DateTime('Europe/Moscow')))), str Array(LowCardinality(Nullable((String)))), fixed_string Array(LowCardinality(Nullable(FixedString(5)))), INDEX idx (i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, date, date_time, str, fixed_string) TYPE bloom_filter GRANULARITY 1) ENGINE = MergeTree() ORDER BY order_key SETTINGS index_granularity = 6;
INSERT INTO test.bloom_filter_array_lc_null_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers LIMIT 15);
INSERT INTO test.bloom_filter_array_lc_null_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers WHERE number >= 5 LIMIT 15);
INSERT INTO test.bloom_filter_array_lc_null_types_test SELECT groupArray(number) AS order_key, groupArray(toInt8(number)) AS i8, groupArray(toInt16(number)) AS i16, groupArray(toInt32(number)) AS i32, groupArray(toInt64(number)) AS i64, groupArray(toUInt8(number)) AS u8, groupArray(toUInt16(number)) AS u16, groupArray(toUInt32(number)) AS u32, groupArray(toUInt64(number)) AS u64, groupArray(toFloat32(number)) AS f32, groupArray(toFloat64(number)) AS f64, groupArray(toDate(number, 'Europe/Moscow')) AS date, groupArray(toDateTime(number, 'Europe/Moscow')) AS date_time, groupArray(toString(number)) AS str, groupArray(toFixedString(toString(number), 5)) AS fixed_string FROM (SELECT number FROM system.numbers WHERE number >= 10 LIMIT 15);
INSERT INTO test.bloom_filter_array_lc_null_types_test SELECT n AS order_key, n AS i8, n AS i16, n AS i32, n AS i64, n AS u8, n AS u16, n AS u32, n AS u64, n AS f32, n AS f64, n AS date, n AS date_time, n AS str, n AS fixed_string FROM (SELECT [NULL] AS n);
INSERT INTO test.bloom_filter_array_lc_null_types_test SELECT [NULL, n] AS order_key, [NULL, toInt8(n)] AS i8, [NULL, toInt16(n)] AS i16, [NULL, toInt32(n)] AS i32, [NULL, toInt64(n)] AS i64, [NULL, toUInt8(n)] AS u8, [NULL, toUInt16(n)] AS u16, [NULL, toUInt32(n)] AS u32, [NULL, toUInt64(n)] AS u64, [NULL, toFloat32(n)] AS f32, [NULL, toFloat64(n)] AS f64, [NULL, toDate(n, 'Europe/Moscow')] AS date, [NULL, toDateTime(n, 'Europe/Moscow')] AS date_time, [NULL, toString(n)] AS str, [NULL, toFixedString(toString(n), 5)] AS fixed_string FROM (SELECT 100 as n);

SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i8, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i16, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i32, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i64, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u8, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u16, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u32, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u64, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f32, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f64, 1);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date, toDate('1970-01-02'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:01', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(str, '1');
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(fixed_string, toFixedString('1', 5));

SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i8, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i16, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i32, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i64, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u8, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u16, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u32, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u64, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f32, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f64, 5);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date, toDate('1970-01-06'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:05', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(str, '5');
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(fixed_string, toFixedString('5', 5));

SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i8, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i16, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i32, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i64, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u8, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u16, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u32, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u64, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f32, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f64, 10);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date, toDate('1970-01-11'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date_time, toDateTime('1970-01-01 03:00:10', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(str, '10');
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(fixed_string, toFixedString('10', 5));

SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i8, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i16, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i32, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i64, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u8, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u16, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u32, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u64, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f32, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f64, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date_time, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(str, NULL);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(fixed_string, NULL);

SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i8, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i16, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i32, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(i64, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u8, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u16, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u32, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(u64, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f32, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(f64, 100);
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date, toDate('1970-04-11'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(date_time, toDateTime('1970-01-01 03:01:40', 'Europe/Moscow'));
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(str, '100');
SELECT COUNT() FROM test.bloom_filter_array_lc_null_types_test WHERE has(fixed_string, toFixedString('100', 5));

DROP TABLE IF EXISTS test.bloom_filter_array_lc_null_types_test;
