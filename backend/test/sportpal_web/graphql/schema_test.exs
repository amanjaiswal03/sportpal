defmodule SportpalWeb.Graphql.SchemaTest do
  use SportpalWeb.ConnCase
  import Sportpal.Factory

  describe "users graphql" do
    @user_query """
    query getUser($id: ID!) {
      user(id: $id) {
        full_name
        email
      }
    }
    """

    test "query: user", %{conn: conn} do
      # insert a user in test db
      user = insert(:user)

      # make a query
      conn =
        post(conn, "/api/graphql", %{
          "query" => @user_query,
          "variables" => %{id: user.id}
        })

      resp =
        conn
        |> json_response(200)

      # assert
      assert resp == %{
               "data" => %{
                 "user" => %{"email" => user.email, "full_name" => user.full_name}
               }
             }
    end
  end

  describe "inquiries graphql" do
    @exact_match_query """
    query myMatch($match: ExactMatchForm!) {
      exactMatches(match: $match) {
        full_name
        profile_pic
        sport
        preferred_skill_level
        city
        country
      }
    }
    """

    test "query: get_matches", %{conn: conn} do
      # first time user
      user_1 = insert(:user)

      # fills the instant match form and submits
      # fails to find a partner
      # wants others to know she is looking for someone
      inquiry_1 = insert(:inquiry, %{user_id: user_1.id})

      # another user on the platform
      user_2 = insert(:user)

      # fills the form
      # makes a query
      variables = %{
        match: %{
          user_id: user_2.id,
          city: inquiry_1.city,
          country: inquiry_1.country,
          sport: inquiry_1.sport,
          # date: p.date,
          preferred_skill_level: inquiry_1.preferred_skill_level
        }
      }

      conn =
        post(conn, "/api/graphql", %{
          "query" => @exact_match_query,
          "variables" => variables
        })

      resp =
        conn
        |> json_response(200)

      # assert
      assert resp == %{
               "data" => %{
                 "exactMatches" => [
                   %{
                     "profile_pic" => user_1.profile_pic,
                     "full_name" => user_1.full_name,
                     "sport" => inquiry_1.sport,
                     "preferred_skill_level" => inquiry_1.preferred_skill_level,
                     "city" => inquiry_1.city,
                     "country" => inquiry_1.country
                   }
                 ]
               }
             }
    end
  end
end
