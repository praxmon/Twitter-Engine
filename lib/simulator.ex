defmodule Simulator do
    use GenServer

    def start_simulator(init_option, opts) do
        { _ , sim_pid} = GenServer.start(__MODULE__, init_option, opts)
        sim_pid
    end


    def simulate(num_users) do
        sim_name = GenServer.call({:global,:Daddy},{:send_unique_code})
        create_users(num_users, sim_name)
        set_followers(num_users, sim_name)
        send_tweet(num_users,1, sim_name)
    end

    def create_users(num_users, sim_name) do


        range = 1..num_users
        Enum.each(range, fn(user_id) -> (
            client_name = "#{sim_name}c#{user_id}"
            client_name=String.to_atom(client_name) 
            Client.start_client(client_name)
            GenServer.cast({:global, :Daddy},{:register_user, client_name})
         ) end)

    end

    def set_followers(num_users,sim_name) do
        range = 1..num_users
        #here the user_id is being followed by the follower_id
        Enum.each(range, fn(user_id) -> (
            max_lim = round(Float.floor(num_users/user_id))
            followers_range= 1..max_lim
            Enum.each(followers_range, fn(follower_id) -> (
                user_id_atom = String.to_existing_atom("#{sim_name}c#{user_id}")
                if(follower_id != user_id) do
                    follower_id_atom = String.to_existing_atom("#{sim_name}c#{follower_id}")
                    #might want to do a random selection instead...
                    GenServer.cast({:global, :Daddy},{:subscribe, user_id_atom, follower_id_atom})
                end
             ) end)

        )end)
    end

    def send_tweet(num_users, num_tweets, sim_name) do
        user_range= 1..num_users
        
        Enum.each(user_range, fn(user_id) -> (
            random_tweet=Client.random_tweet(num_users)
            user_id_atom=String.to_existing_atom("#{sim_name}c#{user_id}")
            GenServer.cast({:global , :Daddy},{:tweet, user_id_atom, random_tweet})
         ) end)

        #can call it recursively...
    end
end