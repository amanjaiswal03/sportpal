defmodule Sportpal.Inquiries.Inquiries do
  import Ecto.Query
  alias Sportpal.Repo
  alias Sportpal.Inquiries.Inquiry

  def get_matches(
        %{
          user_id: user_id,
          city: city,
          country: country,
          sport: sport,
          # date: date,
          preferred_skill_level: preferred_skill_level
        } = _args
      ) do
    # find the inquiry
    matching_inquiry =
      from i in Inquiry,
        # TODO: Fix-the date type do not match
        # i.date == ^date and
        # make sure it is not his own entry
        where:
          i.user_id != ^user_id and
            i.city == ^city and
            i.country == ^country and
            i.sport == ^sport and
            i.preferred_skill_level == ^preferred_skill_level

    # preload associated user
    query =
      from i in matching_inquiry,
        # To avoid a separate query for preload
        # See- https://hexdocs.pm/ecto/Ecto.Query.html#preload/3
        join: u in assoc(i, :user),
        preload: [user: u]

    Repo.all(query)
  end
end
