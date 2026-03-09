#!/usr/bin/env python3
"""
Quick script to test database connectivity and check phone numbers in the database.
This helps debug password reset issues.
"""

import os
import oracledb

# Database configuration
DB_USER = os.getenv("DB_USERNAME", "system")
DB_PASSWORD = os.getenv("DB_PASSWORD", "thoutha")
DB_DSN = os.getenv("DB_DSN", "localhost:1521/XE")

print("="*60)
print("Database Phone Number Test")
print("="*60)
print(f"Connecting to: {DB_DSN}")
print(f"User: {DB_USER}")
print()

try:
    # Connect to database
    conn = oracledb.connect(
        user=DB_USER,
        password=DB_PASSWORD,
        dsn=DB_DSN
    )
    print("✓ Database connection successful!")
    print()
    
    cursor = conn.cursor()
    
    # Check DOCTOR table
    print("-" * 60)
    print("DOCTOR Table - All Phone Numbers:")
    print("-" * 60)
    try:
        cursor.execute("""
            SELECT ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER 
            FROM DOCTOR 
            ORDER BY ID
        """)
        
        doctors = cursor.fetchall()
        if doctors:
            for doc in doctors:
                print(f"ID: {doc[0]}, Name: {doc[1]} {doc[2]}")
                print(f"  Email: {doc[3]}")
                print(f"  Phone: '{doc[4]}' (length: {len(doc[4]) if doc[4] else 0})")
                print()
        else:
            print("No doctors found in database.")
    except Exception as e:
        print(f"Error querying DOCTOR table: {e}")
    
    print()
    
    # Check PATIENTS table
    print("-" * 60)
    print("PATIENTS Table - All Phone Numbers:")
    print("-" * 60)
    try:
        cursor.execute("""
            SELECT ID, FIRST_NAME, LAST_NAME, PHONE_NUMBER 
            FROM PATIENTS 
            ORDER BY ID
        """)
        
        patients = cursor.fetchall()
        if patients:
            for pat in patients:
                print(f"ID: {pat[0]}, Name: {pat[1]} {pat[2]}")
                print(f"  Phone: '{pat[3]}' (length: {len(pat[3]) if pat[3] else 0})")
                print()
        else:
            print("No patients found in database.")
    except Exception as e:
        print(f"Error querying PATIENTS table: {e}")
    
    print()
    
    # Test phone number search
    print("-" * 60)
    print("Phone Number Search Test:")
    print("-" * 60)
    test_phone = input("Enter phone number to search (e.g., +1234567890): ").strip()
    
    if test_phone:
        # Exact match
        cursor.execute("""
            SELECT ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER 
            FROM DOCTOR 
            WHERE PHONE_NUMBER = :phone
        """, {"phone": test_phone})
        
        result = cursor.fetchone()
        if result:
            print(f"✓ EXACT MATCH found in DOCTOR table:")
            print(f"  ID: {result[0]}, Name: {result[1]} {result[2]}")
            print(f"  Phone: '{result[4]}'")
        else:
            print(f"✗ No exact match for '{test_phone}'")
            
            # Try flexible match
            cursor.execute("""
                SELECT ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER 
                FROM DOCTOR 
                WHERE REPLACE(REPLACE(REPLACE(PHONE_NUMBER, ' ', ''), '-', ''), '+', '') = 
                      REPLACE(:phone, '+', '')
            """, {"phone": test_phone.replace(' ', '').replace('-', '')})
            
            result = cursor.fetchone()
            if result:
                print(f"✓ FLEXIBLE MATCH found in DOCTOR table:")
                print(f"  ID: {result[0]}, Name: {result[1]} {result[2]}")
                print(f"  Phone in DB: '{result[4]}'")
                print(f"  Searched for: '{test_phone}'")
            else:
                print(f"✗ No flexible match either. Check if phone number exists in database.")
    
    cursor.close()
    conn.close()
    
    print()
    print("="*60)
    print("Test completed!")
    print("="*60)
    
except oracledb.DatabaseError as e:
    print(f"✗ Database error: {e}")
except Exception as e:
    print(f"✗ Error: {e}")
