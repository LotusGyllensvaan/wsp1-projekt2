class App < Sinatra::Base

    get '/' do
        erb(:"index")
    end

    get '/tasks' do
        @tasks = db.execute('SELECT * FROM tasks')
        erb(:"tasks/index")
    end

end
