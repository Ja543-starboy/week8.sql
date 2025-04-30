from fastapi import FastAPI, HTTPException
import mysql.connector
from pydantic import BaseModel
from typing import Optional

app = FastAPI()

# Database connection
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="your_username",
        password="your_password",
        database="library_db"
    )

# Models
class MemberCreate(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone: Optional[str] = None
    membership_status: Optional[str] = "active"

class BookCreate(BaseModel):
    isbn: str
    title: str
    author: str
    publisher: Optional[str] = None
    publication_year: Optional[int] = None
    genre: Optional[str] = None
    total_copies: int = 1

# Members CRUD
@app.post("/members/", status_code=201)
def create_member(member: MemberCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            "INSERT INTO members (first_name, last_name, email, phone, join_date, membership_status) "
            "VALUES (%s, %s, %s, %s, CURDATE(), %s)",
            (member.first_name, member.last_name, member.email, member.phone, member.membership_status)
        )
        conn.commit()
        return {"message": "Member created successfully"}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))
    finally:
        cursor.close()
        conn.close()

@app.get("/members/")
def read_members():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM members")
    members = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return members

# Books CRUD
@app.post("/books/", status_code=201)
def create_book(book: BookCreate):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            "INSERT INTO books (isbn, title, author, publisher, publication_year, genre, total_copies, available_copies) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (book.isbn, book.title, book.author, book.publisher, book.publication_year, 
             book.genre, book.total_copies, book.total_copies)
        )
        conn.commit()
        return {"message": "Book added successfully"}
    except mysql.connector.Error as err:
        raise HTTPException(status_code=400, detail=str(err))
    finally:
        cursor.close()
        conn.close()

@app.get("/books/")
def read_books():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM books")
    books = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return books

# Loans operations
@app.post("/loans/", status_code=201)
def create_loan(member_id: int, book_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Check book availability
        cursor.execute("SELECT available_copies FROM books WHERE book_id = %s", (book_id,))
        result = cursor.fetchone()
        
        if not result or result[0] < 1:
            raise HTTPException(status_code=400, detail="Book not available")
        
        # Create loan
        cursor.execute(
            "INSERT INTO loans (member_id, book_id, loan_date, due_date, status) "
            "VALUES (%s, %s, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'active')",
            (member_id, book_id)
        )
        
        # Update book availability
        cursor.execute(
            "UPDATE books SET available_copies = available_copies - 1 WHERE book_id = %s",
            (book_id,)
        )
        
        conn.commit()
        return {"message": "Loan created successfully"}
    except mysql.connector.Error as err:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(err))
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)