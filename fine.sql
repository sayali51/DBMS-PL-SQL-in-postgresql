-- Drop tables if they exist
DROP TABLE IF EXISTS Fine;
DROP TABLE IF EXISTS Borrower;

-- Create Borrower table
CREATE TABLE Borrower (
    Roll_no       INTEGER PRIMARY KEY,
    Name          VARCHAR(25),
    DateOfIssue   DATE,
    NameOfBook    VARCHAR(50),
    Status        VARCHAR(10)
);

-- Insert sample data
INSERT INTO Borrower VALUES
(45, 'SEJAL',  TO_DATE('01-08-2022', 'DD-MM-YYYY'), 'HARRY POTTER', ''),
(46, 'ARYA',   TO_DATE('15-08-2022', 'DD-MM-YYYY'), 'DARK MATTER', ''),
(47, 'TRIVENI',TO_DATE('24-08-2022', 'DD-MM-YYYY'), 'SILENT HILL', ''),
(48, 'SANKET', TO_DATE('26-08-2022', 'DD-MM-YYYY'), 'GOD OF WAR', ''),
(49, 'SARTHAK',TO_DATE('09-09-2022', 'DD-MM-YYYY'), 'SPIDER-MAN', '');

-- Create Fine table
CREATE TABLE Fine (
    Roll_no     INTEGER,
    Return_date DATE,
    Amt         NUMERIC(10,2)
);

-- Create or replace procedure
CREATE OR REPLACE PROCEDURE proc_BookReturn(
    p_roll_no INTEGER,
    p_nameofbook VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dateofissue DATE;
    v_days INTEGER;
    v_fine NUMERIC(10,2) := 0;
    v_return_date DATE := CURRENT_DATE;
BEGIN
    -- Get issue date
    SELECT DateOfIssue INTO v_dateofissue
    FROM Borrower
    WHERE Roll_no = p_roll_no
      AND NameOfBook = p_nameofbook;

    v_days := v_return_date - v_dateofissue;

    -- Fine logic
    IF v_days > 30 THEN
        v_fine := (v_days - 30) * 10;   -- example: ₹10 per day after 30
    ELSIF v_days > 15 THEN
        v_fine := (v_days - 15) * 5;    -- ₹5 per day after 15
    ELSE
        v_fine := 0;
    END IF;

    -- Update borrower status
    UPDATE Borrower
    SET Status = 'R'
    WHERE Roll_no = p_roll_no
      AND NameOfBook = p_nameofbook;

    -- Insert into Fine if applicable
    IF v_fine > 0 THEN
        INSERT INTO Fine VALUES (p_roll_no, v_return_date, v_fine);
    END IF;

    RAISE NOTICE 'Book returned by Roll No: %', p_roll_no;
    RAISE NOTICE 'Book: %', p_nameofbook;
    RAISE NOTICE 'Days borrowed: %', v_days;
    RAISE NOTICE 'Fine: %', v_fine;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE NOTICE 'No matching borrower/book found';
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END;
$$;

-- Enable output messages
--set VERBOSITY Verbose

-- Call the procedure
CALL proc_BookReturn(45, 'HARRY POTTER');

-- View results
SELECT * FROM Borrower;
SELECT * FROM Fine;
