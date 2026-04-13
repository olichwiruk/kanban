class CommentsController < ApplicationController
  def create
    @card = Card.find_by(id: params[:card_id])
    return head :bad_request unless @card
    @comment = @card.comments.build(comment_params.merge(author: current_user))

    if @comment.save
      Turbo::StreamsChannel.broadcast_append_to(
        [ @card, "comments" ],
        target: "comments",
        partial: "comments/comment",
        locals: { comment: @comment }
      )

      Turbo::StreamsChannel.broadcast_update_to(
        @card.list.board,
        target: ActionView::RecordIdentifier.dom_id(@card, :comments_counter),
        html: @card.reload.comments_count.to_s
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @card, notice: "Comment was successfully created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def comment_params
    params.require(:comment).permit(:content)
  end
end
