# backend/db_utils.py
import pyodbc
import os
from urllib.parse import quote as url_quote  # Updated import

def get_db_schema(db_name):
    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={os.getenv('DB_SERVER')},{os.getenv('DB_PORT')};"
        f"UID={os.getenv('DB_USER')};"
        f"PWD={os.getenv('DB_PASSWORD')}"
    )
    cursor = conn.cursor()
    
    schema = {}
    try:
        cursor.execute(f"USE {db_name}")
        
        tables_query = """
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_TYPE='BASE TABLE'
        """
        cursor.execute(tables_query)
        tables = cursor.fetchall()
        
        for table in tables:
            table_name = table[0]
            schema[table_name] = []
            
            columns_query = f"""
            SELECT COLUMN_NAME, DATA_TYPE 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME='{table_name}'
            """
            cursor.execute(columns_query)
            columns = cursor.fetchall()  # Fixed typo here
            
            for column in columns:
                schema[table_name].append({'column_name': column[0], 'data_type': column[1]})
    except Exception as e:
        raise Exception(f"Error retrieving schema: {e}")
    finally:
        cursor.close()
        conn.close()
    
    return schema
