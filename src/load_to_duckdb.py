import duckdb

con = duckdb.connect("retail.duckdb")

con.execute("""
    CREATE SCHEMA IF NOT EXISTS retail_raw;
    CREATE OR REPLACE TABLE retail_raw.nike_catalog AS
    SELECT * FROM read_csv_auto('datasets/Global_Nike.csv');
""")

print(con.execute("SELECT COUNT(*) FROM retail_raw.nike_catalog").fetchone())
con.close()
