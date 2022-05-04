class Api::V1::HostsController < ApplicationController
  def index
    hosts = Host.all
    
    render :json => { :hosts => hosts.as_json(:except => [:password, :run_as_sudo, :ssh_port, :user_id, :assigned_items_host, :user_to_connect])}, status: 200
  end

  def show
    @host = Host.find_by(id: params[:id])
    if @host 
        #render json: @host, status:200, except: :password
        render :json => { :host => @host.as_json(:except => [:password, :run_as_sudo, :ssh_port, :user_id, :assigned_items_host, :user_to_connect])}, status: 200
    else
        render json: {error: "Host not found"}, status: 404
    end
  end

  def latest_data
    @host = Host.find_by(id: params[:id])
    if @host 
      latest_values={}
      #iterate to get all assigned items and create latest_values hash
      @host.assigned_items_host.each do |item_id|
        latest_values[Item.find(item_id).item_name] = HostItem.where(host_id: @host.id, item_id: item_id).last.value
        puts latest_values
      end
      if !latest_values.empty?
        render :json => { :items => latest_values.as_json()}, status: 200
      else
        render json: {error: "No items assigned on this host"}, status: 404
      end
    else
      render json: {error: "No host found"}, status: 404
    end
  end
end
