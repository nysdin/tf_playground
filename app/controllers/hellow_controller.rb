class HellowController < ApplicationController
  def index; end

  def test
    User.where("name = '#{params[:name]}'")
  end
end
