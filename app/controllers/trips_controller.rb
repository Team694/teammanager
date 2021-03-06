class TripsController < ApplicationController
  before_action :set_trip, only: [:dashboard, :import, :show, :edit, :update, :destroy]

  # GET /trips
  # GET /trips.json
  def index
    authorize Trip
    @trips = Trip.all
  end

  def dashboard
    authorize Trip
  end

  def import
    authorize Trip
    if request.post?
      @wrong_ids = []
      @on_trip_ids = []
      @osies = trip_params[:students_to_import].split(" ").map(&:to_i)
      for i in @osies
        #Checks to see if the student is not on the trip and the Student exists in the database.
        student = Student.find_by(osis:i)
        unless student
          @wrong_ids << i
          next
        end
        if @trip.students.find_by(osis:i)
          @on_trip_ids << i
        else
          @trip.students << student
          @trip.save
        end
      end
      flash[:flashes] = "The osises in this array: #{@wrong_ids.to_s} do not exist in the database. and the osies in this array: #{@on_trip_ids.to_s} are already on the trip."
    end
  end
  # GET /trips/1
  # GET /trips/1.json
  def show
    authorize Trip
  end

  # GET /trips/new
  def new
    @trip = Trip.new
  end

  # GET /trips/1/edit
  def edit
  end

  # POST /trips
  # POST /trips.json
  def create
    @trip = Trip.new(trip_params)

    respond_to do |format|
      format.js
      if @trip.save
        format.html { redirect_to @trip, notice: 'Trip was successfully created.' }
        format.json { render :show, status: :created, location: @trip }
      else
        format.html { render :new }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    respond_to do |format|
      if @trip.update(trip_params)
        format.html { redirect_to @trip, notice: 'Trip was successfully updated.' }
        format.json { render :show, status: :ok, location: @trip }
      else
        format.html { render :edit }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @trip.destroy
    respond_to do |format|
      format.html { redirect_to trips_url, notice: 'Trip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_trip
    @trip = Trip.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trip_params
    params.require(:trip).permit(:name, :requires_teacher_permission, :students_to_import)
  end
end
