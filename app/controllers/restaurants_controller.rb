class RestaurantsController < ApplicationController
  before_action :find_restaurant, only: [:show, :edit, :update, :destroy]
  def index
    @restaurants = Restaurant.all
  end

  def show
    @fish = Fish.order("name asc")
    @fishorder = FishOrder.new
  end

  def new
    if params[:term]
      response = yelp_search(params[:term], params[:location])
      @restaurants = response["businesses"]

      @restaurant = Restaurant.new(
        name: @restaurants.first["name"],
        address: @restaurants.first["location"]["display_address"].join(" "),
        phone_number: @restaurants.first["phone"],
        email: Faker::Internet.email,
        img_url: @restaurants.first["image_url"],
        url: @restaurants.first["url"],
        coordinates: @restaurants.first["coordinates"].to_s
        )
    else
      @restaurants = []
      @restaurant = Restaurant.new
    end
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    @restaurant.user = current_user
    if @restaurant.save
      redirect_to restaurants_path
    else
      # GO BACK TO THE FORM
      render :new
    end
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    @restaurant.update(restaurant_params)
    redirect_to :back
  end

  def destroy
    @restaurant = Restaurant.find(params[:id])
    @restaurant.destroy
    redirect_to restaurants_path
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :address, :phone_number, :email, :img_url, :url, :coordinates, :term, :location)
  end

  def find_restaurant
    @restaurant = Restaurant.find(params[:id])
  end
end