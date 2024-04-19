class Webui::Users::CannedResponsesController < Webui::WebuiController
  before_action :set_canned_response, only: %i[edit update destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @canned_responses = policy_scope(CannedResponse).page(params[:page])

    @canned_response = CannedResponse.new(user: User.session!)
  end

  def edit
    authorize @canned_response
  end

  def create
    @canned_response = User.session!.canned_responses.new(canned_response_params)

    authorize @canned_response

    if @canned_response.save
      flash[:success] = 'Canned response successfully created!'
      redirect_to canned_responses_path
    else
      flash[:error] = "Failed to create canned response: #{@canned_response.errors.full_messages.to_sentence}."
      render :index
    end
  end

  def update
    authorize @canned_response

    if @canned_response.update(canned_response_params)
      flash[:success] = 'Canned response successfully updated'
    else
      flash[:error] = "Failed to update canned response: #{@canned_response.errors.full_messages.to_sentence}"
    end

    redirect_to canned_responses_url
  end

  def destroy
    authorize @canned_response
    if @canned_response.destroy
      flash[:success] = 'Canned response was successfully deleted.'
    else
      flash[:error] = "Failed to remove canned response: #{@canned_response.errors.full_messages.to_sentence}"
    end

    redirect_to canned_responses_url
  end

  private

  def set_canned_response
    @canned_response = CannedResponse.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to canned_responses_url
  end

  def canned_response_params
    # TODO: remove merge and replace decision_kind with decision_type
    decision_type_number = CannedResponse.decision_kinds[params[:canned_response][:decision_kind]]
    params.require(:canned_response).permit(:title, :content, :decision_kind).merge(decision_type: decision_type_number)
  end
end
