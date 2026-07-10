class Game_Event < Game_Character


  #Detects if the event has a specific comment command at the top (can pass multiple comments to test for as an array)
  def detectCommentCommand(comment_text,event)
    comment_text = [comment_text] if comment_text.is_a?(String)
    page = pbGetActiveEventPage(event)
    return unless page
    first_command = page.list[0]
    return nil if !(first_command.code == 108 || first_command.code == 408)
    comments = first_command.parameters
    return comments.any? { |str| comment_text.include?(str) }
  end


  # def getCommentCommandAtTop
  #   page = pbGetActiveEventPage(event)
  #   first_command = page.list[0]
  #   return nil if !(first_command.code == 108 || first_command.code == 408)
  #   comments = first_command.parameters.first
  #   return comments
  # end





end

