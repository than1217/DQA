import pymysql
import os
import sys
from sshtunnel import SSHTunnelForwarder

def check_orphans():
    # SSH Details
    ssh_host = '10.255.9.40'
    ssh_user = 'tuloy_api'
    ssh_password = 'tul0ytul0yt4y0'
    
    # DB Details (Target through SSH)
    db_host = '10.10.10.133' 
    db_user = 'jfiguero'
    db_password = os.environ.get('DB_PASS', '')
    db_name = 'data_cleaning'
    db_port = 3306

    queries = {
        "1. Orphaned Persons (No roster entry)": """
            SELECT COUNT(*) FROM tbl_person p 
            LEFT JOIN tbl_hh_roster r ON p.person_id = r.person_id 
            WHERE r.person_id IS NULL;
        """,
        "2. Orphaned Household Rosters (Missing Person)": """
            SELECT COUNT(*) FROM tbl_hh_roster r 
            LEFT JOIN tbl_person p ON r.person_id = p.person_id 
            WHERE p.person_id IS NULL;
        """,
        "3. Orphaned Household Rosters (Missing Household)": """
            SELECT COUNT(*) FROM tbl_hh_roster r 
            LEFT JOIN tbl_household h ON r.household_id = h.household_id 
            WHERE h.household_id IS NULL;
        """,
        "4. Orphaned Beneficiaries (Missing Household)": """
            SELECT COUNT(*) FROM tbl_beneficiary b 
            LEFT JOIN tbl_household h ON b.household_id = h.household_id 
            WHERE h.household_id IS NULL;
        """,
        "5. Orphaned Grantees (Missing Beneficiary)": """
            SELECT COUNT(*) FROM tbl_grantee g 
            LEFT JOIN tbl_beneficiary b ON g.beneficiary_id = b.beneficiary_id 
            WHERE b.beneficiary_id IS NULL;
        """,
        "6. Orphaned Grantees (Missing Person)": """
            SELECT COUNT(*) FROM tbl_grantee g 
            LEFT JOIN tbl_person p ON g.person_id = p.person_id 
            WHERE p.person_id IS NULL;
        """
    }

    try:
        print("Establishing SSH tunnel...")
        with SSHTunnelForwarder(
            (ssh_host, 22),
            ssh_username=ssh_user,
            ssh_password=ssh_password,
            remote_bind_address=(db_host, db_port)
        ) as tunnel:
            print("SSH tunnel established.")
            print("Connecting to MySQL...")
            
            connection = pymysql.connect(
                host='127.0.0.1',
                user=db_user,
                password=db_password,
                database=db_name,
                port=tunnel.local_bind_port,
                cursorclass=pymysql.cursors.DictCursor
            )
            print("Connected to database successfully!")
            
            with connection.cursor() as cursor:
                for desc, query in queries.items():
                    print(f"Checking {desc}...")
                    cursor.execute(query)
                    result = cursor.fetchone()
                    count = result['COUNT(*)'] if result else 0
                    if count > 0:
                        print(f"  -> FOUND {count} ORPHANED RECORDS!")
                    else:
                        print(f"  -> All good. No orphans found.")
                    print("-" * 50)
                    
            connection.close()

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    check_orphans()
