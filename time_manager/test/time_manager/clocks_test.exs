defmodule TimeManager.ClocksTest do
  use TimeManager.DataCase

  alias TimeManager.Clocks
  alias TimeManager.UsersFixtures

  describe "clock" do
    alias TimeManager.Clocks.Clock

    import TimeManager.ClocksFixtures

    @invalid_attrs %{status: nil, time: nil, user_id: nil}

    test "list_clock/0 returns all clock" do
      clock = clock_fixture()
      assert Clocks.list_clock() == [clock]
    end

    test "get_clock!/1 returns the clock with given id" do
      clock = clock_fixture()
      assert Clocks.get_clock!(clock.id) == clock
    end

    test "create_clock/1 with valid data creates a clock" do
      valid_attrs = %{status: true, time: ~N[2024-10-07 09:04:00], user_id: UsersFixtures.user_fixture().id}

      assert {:ok, %Clock{} = clock} = Clocks.create_clock(valid_attrs)
      assert clock.status == true
      assert clock.time == ~N[2024-10-07 09:04:00]
    end

    test "create_clock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clocks.create_clock(@invalid_attrs)
    end

    test "update_clock/2 with valid data updates the clock" do
      clock = clock_fixture()
      update_attrs = %{status: false, time: ~N[2024-10-08 09:04:00]}

      assert {:ok, %Clock{} = clock} = Clocks.update_clock(clock, update_attrs)
      assert clock.status == false
      assert clock.time == ~N[2024-10-08 09:04:00]
    end

    test "update_clock/2 with invalid data returns error changeset" do
      clock = clock_fixture()
      assert {:error, %Ecto.Changeset{}} = Clocks.update_clock(clock, @invalid_attrs)
      assert clock == Clocks.get_clock!(clock.id)
    end

    test "delete_clock/1 deletes the clock" do
      clock = clock_fixture()
      assert {:ok, %Clock{}} = Clocks.delete_clock(clock)
      assert_raise Ecto.NoResultsError, fn -> Clocks.get_clock!(clock.id) end
    end

    test "change_clock/1 returns a clock changeset" do
      clock = clock_fixture()
      assert %Ecto.Changeset{} = Clocks.change_clock(clock)
    end
  end
end
