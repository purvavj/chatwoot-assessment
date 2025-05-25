class Api::V1::Accounts::AIAgent::CopilotThreadsController < Api::V1::Accounts::BaseController
  before_action :ensure_message, only: :create

  def index
    @copilot_threads = Current.account.copilot_threads
                              .where(user_id: Current.user.id)
                              .includes(:user, :topic)
                              .order(created_at: :desc)
                              .page(permitted_params[:page] || 1)
                              .per(5)
  end

  def create
    ActiveRecord::Base.transaction do
      @copilot_thread = Current.account.copilot_threads.create!(
        title: copilot_thread_params[:message],
        user: Current.user,
        topic: topic
      )

      @copilot_thread.copilot_messages.create!(message_type: :user, message: copilot_thread_params[:message])
    end
  end

  private

  def ensure_message
    return render_could_not_create_error('Message is required') if copilot_thread_params[:message].blank?
  end

  def topic
    Current.account.aiagent_topics.find(copilot_thread_params[:topic_id])
  end

  def copilot_thread_params
    params.permit(:message, :topic_id)
  end

  def permitted_params
    params.permit(:page)
  end
end
