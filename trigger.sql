-- Create main table
CREATE TABLE lib2 (
    book_name VARCHAR(50),
    status VARCHAR(20)
);

-- Create audit table
CREATE TABLE library_audit (
    date_modified TIMESTAMP,
    book_name VARCHAR(50),
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    action VARCHAR(10)
);

-- Insert sample data
INSERT INTO lib2 VALUES ('WIZARD OF OZ', 'AVAILABLE');
INSERT INTO lib2 VALUES ('KNIGHTS OF THE KINGDOM', 'UNAVAILABLE');
INSERT INTO lib2 VALUES ('APOTHECARY DIARIES', 'AVAILABLE');
INSERT INTO lib2 VALUES ('ONE THOUSAND STITCHES', 'UNAVAILABLE');
INSERT INTO lib2 VALUES ('UNCHARTED', 'AVAILABLE');

-- Create trigger function (PostgreSQL requires function + trigger separately)
CREATE OR REPLACE FUNCTION trigger_3_func()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Old Status: %', OLD.status;
        INSERT INTO library_audit VALUES (NOW(), OLD.book_name, OLD.status, NEW.status, 'UPDATE');

    ELSIF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Inserted Book: %', NEW.book_name;
        INSERT INTO library_audit VALUES (NOW(), NEW.book_name, NULL, NEW.status, 'INSERT');

    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Deleting Book: %', OLD.book_name;
        INSERT INTO library_audit VALUES (NOW(), OLD.book_name, OLD.status, NULL, 'DELETE');
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that calls the function
CREATE TRIGGER trigger_3
AFTER INSERT OR UPDATE OR DELETE ON lib2
FOR EACH ROW
EXECUTE FUNCTION trigger_3_func();

-- Perform some operations
DELETE FROM lib2 WHERE book_name = 'KNIGHTS OF THE KINGDOM';

UPDATE lib2 SET status = 'UNAVAILABLE' WHERE book_name = 'UNCHARTED';
UPDATE lib2 SET status = 'PRE-ORDER' WHERE book_name = 'APOTHECARY DIARIES';

-- View the audit logs
SELECT * FROM library_audit;

-- View remaining library records
SELECT * FROM lib2;
