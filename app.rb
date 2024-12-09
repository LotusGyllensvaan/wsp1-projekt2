class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/tasks.sqlite")
        @db.results_as_hash = true
        
        return @db
    end

    
    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    get '/' do
        redirect("/tasks")
        if session[:user_id]
            erb(:"admin/index")
          else
            erb :index
          end
    end

    get '/admin' do
        if session[:user_id]
          erb(:"admin/index")
        else
          p "/admin : Access denied."
          status 401
          redirect '/unauthorized'
        end
    end

    get '/unauthorized' do
        erb(:unauthorized)
    end

    get '/tasks' do
        @tasks = db.execute('SELECT * FROM tasks')
        @ongoing_tasks = db.execute('SELECT * FROM tasks WHERE ongoing = 1')
        @completed_tasks = db.execute('SELECT * FROM tasks WHERE ongoing = 0')
        erb(:"index")
    end
    post '/tasks' do    
        db.execute("INSERT INTO tasks (title, description, ongoing, category) VALUES(?,?,?,?)", 
        [
            params['task_title'], 
            params['task_description'],
            1,
            params['task_category']
        ])
        redirect("/tasks")
    end


    post '/tasks/:id/delete' do |id|
        db.execute('DELETE FROM tasks WHERE Id = ?', id)
        redirect("/tasks")
    end

    get '/tasks/:id/edit' do | id |
        @task = db.execute('SELECT * FROM tasks WHERE Id = ?', id).first
        erb(:"change")
    end

    post '/tasks/:id/complete' do | id |
        db.execute(
            'UPDATE tasks
            SET
                ongoing = 0
            WHERE Id = ?', id)
        redirect("/tasks")
    end

    post '/tasks/:id/uncomplete' do | id |
        db.execute(
            'UPDATE tasks
            SET
                ongoing = 1
            WHERE Id = ?', id)
        redirect("/tasks")
    end

    post '/tasks/:id/update' do | id |
        db.execute("
        UPDATE tasks 
        SET
            title = ?,
            description = ?,
            category = ?
        WHERE 
            id = ?
        ", 
        [
            params['task_title'], 
            params['task_description'],
            params['task_category'],
            id
        ])
        redirect("/tasks")
    end

    post '/login' do
        request_username = params[:username]
        request_plain_password = params[:password]
    
        user = db.execute("SELECT *
                FROM users
                WHERE username = ?",
                request_username).first
    
        unless user
          p "/login : Invalid username."
          status 401
          redirect '/unauthorized'
        end
    
        db_id = user["id"].to_i
        db_password_hashed = user["password"].to_s
    
        # Create a BCrypt object from the hashed password from db
        bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
        # Check if the plain password matches the hashed password from db
        if bcrypt_db_password == request_plain_password
          session[:user_id] = db_id
          redirect '/admin'
        else
          status 401
          redirect '/unauthorized'
        end
    
      end

      get '/logout' do
        p "/logout : Logging out"
        session.clear
        redirect '/'
      end
end