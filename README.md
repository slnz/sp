# Sp
Rails app to track Summer Project Application process.  

## Development Environment

0. Make sure these are installed and running.  
    
    ```
    Ruby  
    Rails  
    MySQL  
    Memcahced  
    ```

1. Clone git repo

    ```
    git clone git://github.com/westonplatter/sp.git
    ```

2. Copy configuration/initializer files

    ```
    cd sp
    cp config/database.example.yml     config/database.yml  
    cp config/config.example.yml       config/config.yml  
    ```

3. Install dependent Ruby gems, 

    ```
    bundle install
    ```

4. Create database,

    ```
    rake db:create
    ```

5. Run test suite, 

    ```
    rake spec
    ```


## Test Environment

## Production Environment  


