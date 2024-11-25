class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/tasks.sqlite")
        @db.results_as_hash = true
        
        return @db
    end

    get '/' do
        redirect("/tasks")
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
end