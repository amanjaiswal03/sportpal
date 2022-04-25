defmodule Sportpal.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Sportpal.Repo

  alias Faker.{Address, Lorem, Person, File, Date}
  alias Sportpal.Inquiries.Inquiry
  alias Sportpal.Accounts.User
  alias Sportpal.Invitations.Invitation

  def user_factory do
    %User{
      id: System.unique_integer([:positive]),
      full_name: "#{Person.first_name()} #{Person.last_name()}",
      username: Lorem.word(),
      email: sequence(:email, &"user#{&1}@mail.com"),
      hashed_password: "some_super_secure_pwd",
      gender:
        sequence(:gender, [
          "woman",
          "man",
          "transgender",
          "non_binary/non_conforming",
          "prefer_not_to_respond"
        ]),
      profile_pic: File.file_name(:image),
      city: Address.city(),
      country: Address.En.country(),
      bio: Lorem.paragraph(),
      date_of_birth: Date.date_of_birth(),
      sports: %{
        tennis: "beginner",
        cricket: "advanced"
      },
      availability: ["sunday", "wednesday"],
      matching_partners: [123, 456],
      confirmed_at: ~U[2016-05-24 13:26:08.003Z]
    }
  end

  def inquiry_factory do
    %Inquiry{
      id: System.unique_integer([:positive]),
      user_id: System.unique_integer([:positive]),
      city: Address.city(),
      country: Address.En.country(),
      sport: Lorem.word(),
      date: ~U[2016-05-24 13:26:08.003Z],
      preferred_skill_level:
        sequence(:preferred_skill_level, ["beginner", "intermediate", "expert", "any"])
    }
  end

  def invitation_factory do
    %Invitation{
      id: System.unique_integer([:positive]),
      inquiry_id: System.unique_integer([:positive]),
      from_id: System.unique_integer([:positive]),
      from_decision: sequence(:from_decision, ["pending", "confirmed", "declined"]),
      to_id: System.unique_integer([:positive]),
      to_decision: sequence(:from_decision, ["pending", "confirmed", "declined"])
    }
  end
end
