class BathroomsController < ApplicationController
  before_action :set_bathroom, only: [:show, :edit, :update, :destroy]

  # GET /bathrooms
  # GET /bathrooms.json
  def index
    @bathrooms = Bathroom.all
  end

  # GET /bathrooms/1
  # GET /bathrooms/1.json
  def show
  end

  # GET /bathrooms/new
  def new
    @bathroom = Bathroom.new
  end

  # GET /bathrooms/1/edit
  def edit
  end

  def stats
    render json: StallStatsAggregate::create_buckets(Bathroom.all.first, 30, Time.now.beginning_of_day)
  end

  def set_stall_status
    begin
      set_bathroom
      stall = @bathroom.stalls.where(number: params[:stall_id])
      state = to_boolean(params[:state])

      if ( stall[0].state != state )
        stall.update_all(state: state)

        bathroomData = Bathroom.all.map do |b|
          stalls = b.stalls.map do |s|
            { id: s.id, state: s.state }
            if (s.state == true)
              stallStats = StallStats.create(usage_start: Time.now, stall_id: s.id)
            else
              begin
                stallStats = StallStats.find_by(stall_id: s.id, usage_end: nil)
                stallStats.usage_end = Time.now
                stallStats.save
              rescue
                # prevent error from bubbling up
              end
            end

          end
          { id: b.id, name: b.name, stalls: stalls, is_full: b.is_full? }
        end

        ::WebsocketRails[:"bathroom"].trigger "bathroom_update", bathroomData
      end

      render plain: "OK"
    rescue => e
      render plain: "FAIL"
    end
  end


  # POST /bathrooms
  # POST /bathrooms.json
  def create
    @bathroom = Bathroom.new(bathroom_params.except(:stalls))
    num_stalls = bathroom_params[:stalls].to_i

    respond_to do |format|
      if @bathroom.save
        (0..(num_stalls - 1)).each do |i|
          Stall.new({ bathroom_id: @bathroom.id, state: false, number: @bathroom.stalls.count }).save
        end
        format.html { redirect_to @bathroom, notice: 'Bathroom was successfully created.' }
        format.json { render :show, status: :created, location: @bathroom }
      else
        format.html { render :new }
        format.json { render json: @bathroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bathrooms/1
  # PATCH/PUT /bathrooms/1.json
  def update
    num_stalls = bathroom_params[:stalls].to_i
    respond_to do |format|
      if @bathroom.update(bathroom_params.except(:stalls))
        if num_stalls > @bathroom.stalls.count
          (@bathroom.stalls.count..num_stalls).each do |i|
            Stall.new({ bathroom_id: @bathroom.id, state: false, number: @bathroom.stalls.count }).save
          end
        elsif num_stalls < @bathroom.stalls.count && num_stalls >= 0
          while num_stalls < @bathroom.stalls.count do
            @bathroom.stalls.last.destroy
          end
        end
        format.html { redirect_to @bathroom, notice: 'Bathroom was successfully updated.' }
        format.json { render :show, status: :ok, location: @bathroom }
      else
        format.html { render :edit }
        format.json { render json: @bathroom.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bathrooms/1
  # DELETE /bathrooms/1.json
  def destroy
    @bathroom.destroy
    respond_to do |format|
      format.html { redirect_to bathrooms_url, notice: 'Bathroom was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bathroom
      @bathroom = Bathroom.find(params[:id]) rescue Bathroom.find(params[:bathroom_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bathroom_params
      params.require(:bathroom).permit(:name, :token, :stalls)
    end

    def to_boolean(str)
      str == 'true'
    end


end
