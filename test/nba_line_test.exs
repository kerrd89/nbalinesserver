defmodule NbaLineTest do
    use NbaLinesServer.RepoCase
  
    describe "get_nba_lines/0" do
      test "returns an empty array if no nba_lines exist" do
        assert NbaLine.Api.get_nba_lines() == []
      end
    end
  
    describe "create_nba_line/1" do
      test "returns an error if missing params" do
        {:error, message} = NbaLine.Api.create_nba_line(%{})
  
        assert message == [date: {"can't be blank", [validation: :required]}]
      end
    #   test "returns an ok tuple if given valid params" do
    #     url = "https://stackchief.com"
    #     {:ok, blog} = NbaLine.Api.create_blog(%{"url" => url})
  
    #     assert blog.url == url
    #   end
    end
end