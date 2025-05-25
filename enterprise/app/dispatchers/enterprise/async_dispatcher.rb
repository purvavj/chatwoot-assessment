module Enterprise::AsyncDispatcher
  def listeners
    super + [
      AiAgentListener.instance
    ]
  end
end
