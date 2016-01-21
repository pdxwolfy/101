require 'pry'
require 'test/unit'
require './eleventyone.rb'

# rubocop:disable AbcSize
# rubocop:disable MethodLength

require 'stringio'

def capture_stdin(*strings)
  save_in = $stdin
  $stdin = StringIO.new strings.join("\n") + "\n"
  yield
ensure
  $stdin = save_in
end

def capture_stdout
  save_out = $stdout
  $stdout = mock_out = StringIO.new
  yield
  mock_out.string
ensure
  $stdout = save_out
end

# String.clean
class String
  def clean
    gsub(/^ +/, '')
  end
end

def simple_state
  {
    deck: [card(2), card(:A), card(:J), card(9), card(:A)],
    dealer: { hand: [], scores: [0], wins: 0 },
    player: { hand: [], scores: [0], wins: 0 },
    target: BUST
  }
end

SPACE = ' '.freeze

#------------------------------------------------------------------------------
# busted?(state, hand)
class BustedQuery < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_empty_hands
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)
  end

  def test_after_deal
    deal! @state
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)
  end

  def test_at_max
    hit! @state, :player # [A]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [9]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [9, 10]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :player # [A, A]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [9, 10, 2]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)
  end

  def test_with_bust
    hit! @state, :dealer # [A]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [A, 9]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [A, 9, 10]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :player # [A]
    assert !busted?(@state, :player)
    assert !busted?(@state, :dealer)

    hit! @state, :dealer # [A, 9, 10, 2]
    assert !busted?(@state, :player)
    assert busted?(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# card rank
class Card < Test::Unit::TestCase
  self.test_order = :defined

  def test_card
    assert_equal({ rank: 2,  values: [2] }, card(2))
    assert_equal({ rank: 3,  values: [3] }, card(3))
    assert_equal({ rank: 4,  values: [4] }, card(4))
    assert_equal({ rank: 5,  values: [5] }, card(5))
    assert_equal({ rank: 6,  values: [6] }, card(6))
    assert_equal({ rank: 7,  values: [7] }, card(7))
    assert_equal({ rank: 8,  values: [8] }, card(8))
    assert_equal({ rank: 9,  values: [9] }, card(9))
    assert_equal({ rank: 10, values: [10] }, card(10))
    assert_equal({ rank: :J, values: [10] }, card(:J))
    assert_equal({ rank: :Q, values: [10] }, card(:Q))
    assert_equal({ rank: :K, values: [10] }, card(:K))
    assert_equal({ rank: :A, values: [1, 11] }, card(:A))
  end
end

#------------------------------------------------------------------------------
# cards_and_possible_scores(state, hand)
class CardsAndPossibleScores < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_cards_and_possible_scores
    hit! @state, :player, card(3)
    hit! @state, :player, card(10)
    hit! @state, :player, card(8)
    hit! @state, :dealer, card(2)
    hit! @state, :dealer, card(5)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(2)

    assert_equal ['3 10 8', '21'], cards_and_possible_scores(@state, :player)
    assert_equal ['2 5 A 2', '10 or 20'],
                 cards_and_possible_scores(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# cards_for_hand(state, hand)
class CardsForHand < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_empty_hand
    assert_equal '', cards_for_hand(@state, :player)
  end

  def test_1_card_hand
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(10)
    assert_equal 'A', cards_for_hand(@state, :player)
    assert_equal '10', cards_for_hand(@state, :dealer)
  end

  def test_2_and_3_card_hands
    hit! @state, :player, card(:A)
    hit! @state, :player, card(5)
    hit! @state, :dealer, card(8)
    hit! @state, :dealer, card(10)
    hit! @state, :dealer, card(8)
    assert_equal 'A 5', cards_for_hand(@state, :player)
    assert_equal '8 10 8', cards_for_hand(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# check_game_end! state
class CheckGameEndBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_not_end
    out = capture_stdout do
      check_game_end!(@state)
    end
    assert_equal '', out
  end

  def test_player_wins
    got_exit = false
    @state[:player][:wins] = 5
    @state[:dealer][:wins] = 3
    out = capture_stdout do
      begin
        check_game_end!(@state)
      rescue SystemExit
        got_exit = true
      end
    end

    msg = 'Congratulations! You reached 5 wins first, and have won the game ' \
          "5-3.\n"
    assert_equal msg, out
    assert got_exit
  end

  def test_player_loses
    got_exit = false
    @state[:player][:wins] = 2
    @state[:dealer][:wins] = 5
    out = capture_stdout do
      begin
        check_game_end!(@state)
      rescue SystemExit
        got_exit = true
      end
    end

    msg = "Sorry! The dealer reached 5 wins first, and you lost the game 2-5.\n"
    assert_equal msg, out
    assert got_exit
  end
end

#------------------------------------------------------------------------------
# compute_new_scores(state, hand, new_card)
class ComputeNewScores < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_first_card
    assert_equal [2], compute_new_scores(@state, :player, card(2))
    assert_equal [9], compute_new_scores(@state, :dealer, card(9))
    assert_equal [10], compute_new_scores(@state, :player, card(:Q))
    assert_equal [1, 11], compute_new_scores(@state, :dealer, card(:A))
  end

  def test_not_first_card
    hit! @state, :player, card(5)
    hit! @state, :dealer, card(:A)

    assert_equal [7], compute_new_scores(@state, :player, card(2))
    assert_equal [14], compute_new_scores(@state, :player, card(9))
    assert_equal [15], compute_new_scores(@state, :player, card(:Q))
    assert_equal [6, 16], compute_new_scores(@state, :player, card(:A))

    assert_equal [3, 13], compute_new_scores(@state, :dealer, card(2))
    assert_equal [10, 20], compute_new_scores(@state, :dealer, card(9))
    assert_equal [11, 21], compute_new_scores(@state, :dealer, card(:Q))
    assert_equal [2, 12], compute_new_scores(@state, :dealer, card(:A))
  end

  def test_partial_bust
    assert_equal [5], compute_new_scores(@state, :dealer, card(5))
    hit! @state, :dealer, card(5)
    assert_equal [6, 16], compute_new_scores(@state, :dealer, card(:A))
    hit! @state, :dealer, card(:A)
    assert_equal [12], compute_new_scores(@state, :dealer, card(6))
  end

  def test_bust
    hit! @state, :dealer, card(9)
    hit! @state, :dealer, card(10)
    assert_equal [], compute_new_scores(@state, :dealer, card(9))
  end

  def test_bust_non_bust_with_hgher_bust_level
    @state[:target] = 35
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    assert_equal [22], compute_new_scores(@state, :dealer, card(2))
    hit! @state, :dealer, card(2)
    assert_equal [29], compute_new_scores(@state, :dealer, card(7))
    hit! @state, :dealer, card(7)
    assert_equal [], compute_new_scores(@state, :dealer, card(8))
  end

  def test_multiple_aces_higher_target_score
    @state[:target] = 33
    3.times { hit! @state, :player, card(:A) }
    assert_equal [4, 14, 24], compute_new_scores(@state, :player, card(:A))
  end
end

#------------------------------------------------------------------------------
# deal!(state)
class DealBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
    deal! @state
  end

  def test_counts
    assert_equal 2, @state[:player][:hand].size
    assert_equal 1, @state[:dealer][:hand].size
  end

  def test_cards
    assert_equal [card(:A), card(:J)], @state[:player][:hand]
    assert_equal [card(9)], @state[:dealer][:hand]
    assert_equal card(:A), @state[:dealer][:down]
  end
end

#------------------------------------------------------------------------------
# dealer_shows(state, has)
class DealerShows < Test::Unit::TestCase
  self.test_order = :defined

  def test_dealer_shows
    @state = simple_state
    hit! @state, :player, card(3)
    hit! @state, :player, card(10)
    hit! @state, :player, card(8)
    hit! @state, :dealer, card(2)
    hit! @state, :dealer, card(5)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(2)
    out = capture_stdout { dealer_shows @state, 'shows' }
    assert_equal "The dealer shows <2 5 A 2> for 10 or 20 points.\n", out
  end

  def test_dealer_shows_bust
    @state = simple_state
    hit! @state, :dealer, card(2)
    hit! @state, :dealer, card(5)
    hit! @state, :dealer, card(10)
    hit! @state, :dealer, card(2)
    hit! @state, :dealer, card(3)
    out = capture_stdout { dealer_shows @state }
    assert_equal "The dealer has been dealt <2 5 10 2 3> which is a bust.\n",
                 out
  end
end

#------------------------------------------------------------------------------
# dealer_turn?(state)
class DealerTurnQuery < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_1_score
    hit! @state, :dealer, card(6) # 6
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(9) # 15
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(:A) # 16
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(:A) # 17
    assert !dealer_turn?(@state)
  end

  def test_2_scores
    hit! @state, :dealer, card(:A) # 1, 11
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(3) # 4, 14
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(3) # 7, 17
    assert !dealer_turn?(@state)

    hit! @state, :player, card(9) # 9
    hit! @state, :player, card(10) # 19
    assert dealer_turn?(@state)
    hit! @state, :dealer, card(2) # 9, 19
    assert !dealer_turn?(@state)

    hit! @state, :dealer, card(5) # 14
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(2) # 16
    assert dealer_turn?(@state)

    hit! @state, :dealer, card(4) # 20
    assert !dealer_turn?(@state)
  end

  def test_9_or_19_vs_8 # regression test
    hit! @state, :player, card(7)
    hit! @state, :dealer, card(5)
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(3)
    hit! @state, :dealer, card(:A)
    assert !dealer_turn?(@state)
  end
end

#------------------------------------------------------------------------------
# end_of_play_messae(state, hand, whohas)
class EndOfPlayMessage < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_max
    hit! @state, :player, card(3)
    hit! @state, :player, card(10)
    hit! @state, :player, card(8)
    assert_equal "#{BUST}!", end_of_play_message(@state, :player)
  end

  def test_bust
    hit! @state, :dealer, card(3)
    hit! @state, :dealer, card(10)
    hit! @state, :dealer, card(9)
    assert_equal 'busted.', end_of_play_message(@state, :dealer)
  end

  def test_stay
    hit! @state, :player, card(3)
    hit! @state, :player, card(10)
    hit! @state, :player, card(4)
    assert_equal 'stayed at 17 points.', end_of_play_message(@state, :player)
  end
end

#------------------------------------------------------------------------------
# final_score(state, hand)
class FinalScore < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_empty_hands
    assert_equal 0, final_score(@state, :player)
    assert_equal 0, final_score(@state, :dealer)
  end

  def test_after_deal
    deal! @state
    assert_equal 21, final_score(@state, :player)
    assert_equal 9, final_score(@state, :dealer)
  end

  def test_at_max
    hit! @state, :player # [A]
    assert_equal 11, final_score(@state, :player)
    assert_equal 0, final_score(@state, :dealer)

    hit! @state, :dealer # [9]
    assert_equal 11, final_score(@state, :player)
    assert_equal 9, final_score(@state, :dealer)

    hit! @state, :dealer # [9, 10]
    assert_equal 11, final_score(@state, :player)
    assert_equal 19, final_score(@state, :dealer)

    hit! @state, :player # [A, A]
    assert_equal 12, final_score(@state, :player)
    assert_equal 19, final_score(@state, :dealer)

    hit! @state, :dealer # [9, 10, 2]
    assert_equal 12, final_score(@state, :player)
    assert_equal 21, final_score(@state, :dealer)
  end

  def test_with_bust
    hit! @state, :dealer # [A]
    assert_equal 0, final_score(@state, :player)
    assert_equal 11, final_score(@state, :dealer)

    hit! @state, :dealer # [A, 9]
    assert_equal 0, final_score(@state, :player)
    assert_equal 20, final_score(@state, :dealer)

    hit! @state, :dealer # [A, 9, 10]
    assert_equal 0, final_score(@state, :player)
    assert_equal 20, final_score(@state, :dealer)

    hit! @state, :player # [A]
    assert_equal 11, final_score(@state, :player)
    assert_equal 20, final_score(@state, :dealer)

    hit! @state, :dealer # [A, 9, 10, 2]
    assert_equal 11, final_score(@state, :player)
    assert_nil final_score(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# flip_dealer_card!
class FlipDealerCardBang < Test::Unit::TestCase
  self.test_order = :defined

  def test_flip
    @state = simple_state
    @state[:deck] = [card(10), card(:A), card(5), card(8)]
    deal! @state
    flip_dealer_card! @state
    assert_equal [card(5), card(10)], @state[:dealer][:hand]
    assert_equal [15], @state[:dealer][:scores]
  end
end

#------------------------------------------------------------------------------
# get_card_from_deck!(state)
class GetCardFromDeckBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
    @state[:deck] = [card(10), card(:A), card(5), card(8), card(3)]
    deal! @state
    flip_dealer_card! @state
  end

  def test_get_last_card
    assert_equal card(10), get_card_from_deck!(@state)
    assert_equal [], @state[:deck]
  end

  def test_get_card_from_new_deck
    get_card_from_deck! @state
    out = capture_stdout do
      get_card_from_deck! @state
    end
    assert_equal "\n*** A new deck has been put into play. ***\n\n", out

    the_card = nil
    ten_card = card 10
    loop do
      the_card = get_card_from_deck!(@state)
      break unless the_card == ten_card
    end
    assert @state[:deck].size < 52
    assert @state[:deck].size > 48
    assert_not_equal ten_card, the_card
  end
end

#------------------------------------------------------------------------------
# hit!(state, hand)
class HitBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_counts
    hit! @state, :player
    assert_equal 1, @state[:player][:hand].size

    hit! @state, :player
    assert_equal 2, @state[:player][:hand].size

    hit! @state, :player
    assert_equal 3, @state[:player][:hand].size

    hit! @state, :player
    assert_equal 4, @state[:player][:hand].size

    hit! @state, :player
    assert_equal 5, @state[:player][:hand].size
  end

  def test_ranks
    hit! @state, :player
    assert_equal [card(:A)], @state[:player][:hand]

    hit! @state, :player
    hit! @state, :player
    hit! @state, :player
    hit! @state, :player
    assert_equal [card(:A), card(9), card(:J), card(:A), card(2)],
                 @state[:player][:hand]
  end

  def test_scores
    assert_equal [0], @state[:player][:scores]
    assert_equal [0], @state[:dealer][:scores]

    hit! @state, :dealer
    assert_equal [1, 11], @state[:dealer][:scores]

    hit! @state, :dealer
    assert_equal [10, 20], @state[:dealer][:scores]

    hit! @state, :dealer
    assert_equal [20], @state[:dealer][:scores]

    hit! @state, :dealer
    assert_equal [21], @state[:dealer][:scores]

    hit! @state, :dealer
    assert_equal [], @state[:dealer][:scores]
  end

  def test_ranks_direct
    hit! @state, :player, card(2)
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(8)
    assert_equal [card(2), card(:A)], @state[:player][:hand]
    assert_equal [card(:J), card(8)], @state[:dealer][:hand]
  end

  def test_scores_direct
    hit! @state, :player, card(2)
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(8)
    assert_equal [3, 13], @state[:player][:scores]
    assert_equal [18], @state[:dealer][:scores]
  end
end

#------------------------------------------------------------------------------
# join_or(list, sep = ', ', final = 'or')
class JoinOr < Test::Unit::TestCase
  self.test_order = :defined

  def test_empty_list
    assert_equal '', join_or([])
  end

  def test_one_item_list
    assert_equal 'abc', join_or(%w(abc))
  end

  def test_two_item_list
    assert_equal 'abc or def', join_or(%w(abc def))
  end

  def test_two_item_list_with_and
    assert_equal 'abc and def', join_or(%w(abc def), ', ', 'and')
  end

  def test_two_item_list_with_sep
    assert_equal 'abc and def', join_or(%w(abc def), '/', 'and')
  end

  def test_three_item_list
    assert_equal 'abc, xyz, or def', join_or(%w(abc xyz def))
  end

  def test_three_item_list_with_and
    assert_equal 'abc, xyz, and def', join_or(%w(abc xyz def), ', ', 'and')
  end

  def test_three_item_list_with_sep
    assert_equal 'abc/xyz/def', join_or(%w(abc xyz def), '/', '')
  end
end

#------------------------------------------------------------------------------
# max_score?(state, hand)
class MaxScoreQuery < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
    @state[:deck] = [card(2), card(:A), card(9), card(10), card(10)]
  end

  def test_empty_hands
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)
  end

  def test_after_deal
    deal! @state
    hit! @state, :player
    assert max_score?(@state, :player)
    assert !max_score?(@state, :dealer)
  end

  def test_at_max
    hit! @state, :player # [A]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :dealer # [9]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :dealer # [9, 10]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :player # [A, A]
    assert max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :dealer # [9, 10, 2]
    assert max_score?(@state, :player)
    assert max_score?(@state, :dealer)
  end

  def test_with_bust
    hit! @state, :dealer # [10]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :dealer # [10, 10]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :player # [9]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)

    hit! @state, :dealer # [10, 10, A]
    assert !max_score?(@state, :player)
    assert max_score?(@state, :dealer)

    hit! @state, :dealer # [2, 9]
    assert !max_score?(@state, :player)
    assert !max_score?(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# new_deck
class NewDeck < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @deck = new_deck
  end

  def test_type
    assert_instance_of Array, @deck
  end

  def test_size
    assert_equal 52, @deck.size
  end

  def test_counts
    ranks = (2..10).to_a + [:J, :Q, :K, :A]
    ranks.each do |rank|
      count = @deck.count { |the_card| the_card[:rank] == rank }
      assert_equal 4, count, "rank: #{rank}"
    end
  end

  def test_ranks
    ranks = (2..10).to_a + [:J, :Q, :K, :A]
    @deck.each { |the_card| assert ranks.include? the_card[:rank] }
  end

  def test_values
    values = [[2], [3], [4], [5], [6], [7], [8], [9], [10], [1, 11]]
    @deck.each { |the_card| assert values.include? the_card[:values] }
  end
end

#------------------------------------------------------------------------------
# play!(state)
class PlayBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_play_no_hits_21_for_player
    @state[:deck] = [card(9), card(:A), card(10), card(:J)]
    out = capture_stdout { play! @state }
    assert_equal(<<-EOS.clean, out)
      You have won 0 games; the dealer has won 0.
      You have been dealt <J A> for 11 or 21 points.
      You have #{BUST}!

      The dealer has been dealt <10 9> for 19 points.

      Dealer has stayed at 19 points.

      You won 21-19!
    EOS
  end

  def test_play_no_hits_dealer_wins
    @state[:deck] = [card(9), card(8), card(10), card(:J)]
    out = capture_stdout do
      capture_stdin('stay') { play! @state }
    end
    assert_equal(<<-EOS.clean, out)
      You have won 0 games; the dealer has won 0.
      You have been dealt <J 8> for 18 points.
      The dealer shows <10> for 10 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have stayed at 18 points.

      The dealer has been dealt <10 9> for 19 points.

      Dealer has stayed at 19 points.

      Dealer won 19-18.
    EOS
  end

  def test_play_both_players_hit
    @state[:deck] = [card(9), card(7), card(2), card(3), card(10), card(:J)]
    out = capture_stdout do
      capture_stdin(%w(hit stay)) { play! @state }
    end
    assert_equal(<<-EOS.clean, out)
      You have won 0 games; the dealer has won 0.
      You have been dealt <J 3> for 13 points.
      The dealer shows <10> for 10 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have been dealt <J 3 7> for 20 points.
      The dealer shows <10> for 10 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have stayed at 20 points.

      The dealer has been dealt <10 2> for 12 points.
      The dealer has been dealt <10 2 9> for 21 points.

      Dealer has #{BUST}!

      Dealer won 21-20.
    EOS
  end
end

#------------------------------------------------------------------------------
# play_for_dealer!(state)
class PlayForDealerBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_play_hit
    @state[:deck] = [card(10), card(2), card(:A), card(9), card(2), card(6),
                     card(6), card(4)]
    deal! @state
    flip_dealer_card! @state
    out = capture_stdout { play_for_dealer! @state }
    assert_equal(<<-EOS.clean, out)
      The dealer has been dealt <6 2> for 8 points.
      The dealer has been dealt <6 2 9> for 17 points.
    EOS
  end

  def test_play_21
    @state[:deck] = [card(6), card(4), card(2), card(6), card(:J),
                     card(3), card(2)]
    deal! @state
    flip_dealer_card! @state
    out = capture_stdout { play_for_dealer! @state }
    assert_equal(<<-EOS.clean, out)
      The dealer has been dealt <3 6> for 9 points.
      The dealer has been dealt <3 6 2> for 11 points.
      The dealer has been dealt <3 6 2 4> for 15 points.
      The dealer has been dealt <3 6 2 4 6> for 21 points.
    EOS
  end

  def test_play_stay
    @state[:deck] = [card(5), card(3), card(2), card(6), card(4), card(2),
                     card(6), card(:J)]
    deal! @state
    flip_dealer_card! @state
    out = capture_stdout { play_for_dealer! @state }
    assert_equal(<<-EOS.clean, out)
      The dealer has been dealt <6 4> for 10 points.
      The dealer has been dealt <6 4 6> for 16 points.
      The dealer has been dealt <6 4 6 2> for 18 points.
    EOS
  end

  def test_play_with_choice_of_play_or_stay
    @state[:deck] = [card(:K), card(:A), card(3), card(:A), card(5), card(7)]
    deal! @state
    flip_dealer_card! @state
    out = capture_stdout { play_for_dealer! @state }
    assert_equal(<<-EOS.clean, out)
      The dealer has been dealt <5 3> for 8 points.
      The dealer has been dealt <5 3 A> for 9 or 19 points.
    EOS
  end
end

#------------------------------------------------------------------------------
# play_for_player!(state)
class PlayForPlayerBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
    @state[:deck] = [card(2), card(:A), card(9), card(2), card(6), card(6),
                     card(4)]
  end

  def test_play_stay
    deal! @state
    out = capture_stdout do
      capture_stdin('stay') { play_for_player! @state }
    end

    assert_equal(<<-EOS.clean, out)
      You have been dealt <4 6> for 10 points.
      The dealer shows <6> for 6 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
    EOS
  end

  def test_play_21
    @state[:deck] = [card(2), card(:A), card(6), card(:J)]
    deal! @state
    out = capture_stdout { play_for_player! @state }
    assert_equal "You have been dealt <J A> for 11 or 21 points.\n", out
  end

  def test_play_hit_stay
    @state[:deck].push card(6)
    deal! @state
    out = capture_stdout do
      capture_stdin(%w(hit stay)) { play_for_player! @state }
    end

    assert_equal(<<-EOS.clean, out)
      You have been dealt <6 6> for 12 points.
      The dealer shows <4> for 4 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have been dealt <6 6 2> for 14 points.
      The dealer shows <4> for 4 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
    EOS
  end

  def test_play_hit_hit_stay
    @state[:deck].push card(6), card(2)
    deal! @state
    out = capture_stdout do
      capture_stdin(%w(hit H StAy)) { play_for_player! @state }
    end

    assert_equal(<<-EOS.clean, out)
      You have been dealt <2 4> for 6 points.
      The dealer shows <6> for 6 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have been dealt <2 4 6> for 12 points.
      The dealer shows <6> for 6 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      You have been dealt <2 4 6 2> for 14 points.
      The dealer shows <6> for 6 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
    EOS
  end

  def test_play_hit_stay_with_invalid_input
    @state[:deck].push card(6)
    deal! @state
    out = capture_stdout do
      capture_stdin(%w(x hit pass stay)) { play_for_player! @state }
    end

    assert_equal(<<-EOS.clean, out)
      You have been dealt <6 6> for 12 points.
      The dealer shows <4> for 4 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      Invalid response. Please type H to hit, or S to stay.
      >#{SPACE}
      You have been dealt <6 6 2> for 14 points.
      The dealer shows <4> for 4 points.
      Hit (H) or Stay (S)?
      >#{SPACE}
      Invalid response. Please type H to hit, or S to stay.
      >#{SPACE}
    EOS
  end
end

#------------------------------------------------------------------------------
# player_turn?
class PlayerTurnQuery < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @prompt = "Hit (H) or Stay (S)?\n> \n"
    @error = "Invalid response. Please type H to hit, or S to stay.\n> \n"
  end

  def test_stay
    out = capture_stdout do
      capture_stdin('stay') { assert !player_turn? }
    end
    assert_equal @prompt, out
  end

  def test_hit
    out = capture_stdout do
      capture_stdin('hit') { assert player_turn? }
    end
    assert_equal @prompt, out
  end

  def test_abbrev
    out = capture_stdout do
      capture_stdin('St') { assert !player_turn? }
    end
    assert_equal @prompt, out
  end

  def test_bad_input
    out = capture_stdout do
      capture_stdin(%w(x h)) { assert player_turn? }
    end
    assert_equal @prompt + @error, out
  end
end

#------------------------------------------------------------------------------
# plural(quantity)
class Plural < Test::Unit::TestCase
  self.test_order = :defined

  def test_0
    assert_equal 's', plural(0)
  end

  def test_1
    assert_equal '', plural(1)
  end

  def test_2
    assert_equal 's', plural(2)
  end
end

#------------------------------------------------------------------------------
# points_or_bust(scores)
class PointsOrBust < Test::Unit::TestCase
  self.test_order = :defined

  def test_scores
    assert_equal 'for 10 or 20 points.', points_or_bust('10 or 20')
  end

  def test_bust
    assert_equal 'which is a bust.', points_or_bust('')
  end
end

#------------------------------------------------------------------------------
# possible_scores(state, hand, keep_count)
class PossibleScores < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_1_card_hands
    hit! @state, :player, card(5)
    hit! @state, :dealer, card(:A)
    assert_equal '5',       possible_scores(@state, :player)
    assert_equal '1 or 11', possible_scores(@state, :dealer)
  end

  def test_2_card_hands_and_more
    hit! @state, :player, card(5)
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(3)
    assert_equal '6 or 16', possible_scores(@state, :player)
    assert_equal '5 or 15', possible_scores(@state, :dealer)
  end

  def test_3_or_4_possibilities
    @state[:target] = 41
    hit! @state, :player, card(:A)
    hit! @state, :player, card(:A)
    hit! @state, :player, card(3)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(6)
    assert_equal '5, 15, or 25', possible_scores(@state, :player)
    assert_equal '9, 19, 29, or 39', possible_scores(@state, :dealer)
  end
end

#------------------------------------------------------------------------------
# prompt_and_read(msg)
class PromptAndread < Test::Unit::TestCase
  self.test_order = :defined

  def test_prompt_and_read
    answer = nil
    out = capture_stdout do
      capture_stdin('some text') do
        answer = prompt_and_read 'This is a prompt'
      end
    end
    assert_equal "This is a prompt\n> ", out
    assert_equal 'some text', answer
  end
end

#------------------------------------------------------------------------------
# quit!
class QuitBang < Test::Unit::TestCase
  self.test_order = :defined

  def test_quit
    got_exit = false
    out = capture_stdout do
      begin
        quit!('Four score and seven.')
      rescue SystemExit
        got_exit = true
      end
    end
    assert_equal "Four score and seven.\n", out
    assert got_exit
  end
end

#------------------------------------------------------------------------------
# quit?
class QuitQuery < Test::Unit::TestCase
  self.test_order = :defined

  def test_q
    out = capture_stdout do
      capture_stdin('q') { assert quit? }
    end
    assert_equal "Type Q to quit, anything else for next hand.\n> ", out
  end

  def test_quit
    out = capture_stdout do
      capture_stdin('QUIT') { assert quit? }
    end
    assert_equal "Type Q to quit, anything else for next hand.\n> ", out
  end

  def test_no
    out = capture_stdout do
      capture_stdin('no') { assert !quit? }
    end
    assert_equal "Type Q to quit, anything else for next hand.\n> ", out
  end

  def test_nempty
    out = capture_stdout do
      capture_stdin('') { assert !quit? }
    end
    assert_equal "Type Q to quit, anything else for next hand.\n> ", out
  end
end

#------------------------------------------------------------------------------
# record_win!(state)
class RecordWinBang < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
    @state[:dealer][:wins] = @state[:player][:wins] = 2
  end

  def test_dealer_wins
    @state[:deck] = [card(:A), card(10), card(:J), card(10)]
    deal! @state
    flip_dealer_card! @state
    record_win! @state
    assert_equal 2, @state[:player][:wins]
    assert_equal 3, @state[:dealer][:wins]
  end

  def test_player_wins
    @state[:deck] = [card(9), card(10), card(:J), card(10)]
    deal! @state
    flip_dealer_card! @state
    record_win! @state
    assert_equal 3, @state[:player][:wins]
    assert_equal 2, @state[:dealer][:wins]
  end

  def test_tie
    @state[:deck] = [card(:Q), card(:K), card(:J), card(10)]
    deal! @state
    flip_dealer_card! @state
    record_win! @state
    assert_equal 2, @state[:player][:wins]
    assert_equal 2, @state[:dealer][:wins]
  end
end

#------------------------------------------------------------------------------
# report_results(state)
class ReportResults < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_you_busted
    hit! @state, :player, card(:J)
    hit! @state, :player, card(:Q)
    hit! @state, :player, card(:K)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    out = capture_stdout { report_results @state }
    assert_equal "You busted. Dealer wins!\n", out
  end

  def test_dealer_busted
    hit! @state, :player, card(:J)
    hit! @state, :player, card(:Q)
    hit! @state, :dealer, card(:K)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    out = capture_stdout { report_results @state }
    assert_equal "Dealer busted. You win!\n", out
  end

  def test_you_win
    hit! @state, :player, card(:J)
    hit! @state, :player, card(:Q)
    hit! @state, :player, card(:A)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    out = capture_stdout { report_results @state }
    assert_equal "You won 21-20!\n", out
  end

  def test_dealer_wins
    hit! @state, :player, card(:J)
    hit! @state, :player, card(:Q)
    hit! @state, :dealer, card(:A)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    out = capture_stdout { report_results @state }
    assert_equal "Dealer won 21-20.\n", out
  end

  def test_tie_game
    hit! @state, :player, card(:J)
    hit! @state, :player, card(:Q)
    hit! @state, :dealer, card(:J)
    hit! @state, :dealer, card(10)
    out = capture_stdout { report_results @state }
    assert_equal "Tie game: 20-20.\n", out
  end
end

#------------------------------------------------------------------------------
# reset!(state)
class ResetBang < Test::Unit::TestCase
  self.test_order = :defined

  def test_reset
    state = {
      target: BUST,
      player: { money: 200 },
      dealer: { money: 200 }
    }

    reset! state
    assert state.key? :deck
    assert_equal 52, state[:deck].size
    assert_equal [], state[:player][:hand]
    assert_equal [], state[:dealer][:hand]
    assert_equal [0], state[:player][:scores]
    assert_equal [0], state[:dealer][:scores]
  end
end

#------------------------------------------------------------------------------
# solicit_bust_value
class SolicitBustValue < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @prompt = "\nWhat score should each hand play to? (default: #{BUST})\n> \n"
    @error = "Please enter a value between 11 and 170, inclusive.\n> \n"
  end

  def test_default
    out = capture_stdout do
      capture_stdin('') { assert_equal BUST, solicit_bust_value }
    end
    assert_equal @prompt, out
  end

  def test_11
    out = capture_stdout do
      capture_stdin('11') { assert_equal 11, solicit_bust_value }
    end
    assert_equal @prompt, out
  end

  def test_170
    out = capture_stdout do
      capture_stdin('170') { assert_equal 170, solicit_bust_value }
    end
    assert_equal @prompt, out
  end

  def test_bad_input
    out = capture_stdout do
      capture_stdin(%w(10 171 31)) { assert_equal 31, solicit_bust_value }
    end
    assert_equal @prompt + @error * 2, out
  end
end

#------------------------------------------------------------------------------
# to_integer(value, default, min, max)
class ToInteger < Test::Unit::TestCase
  self.test_order = :defined

  def test_use_default_value
    assert_equal 423, to_integer('', 423, 50, 500)
  end

  def test_use_non_default_value
    assert_equal 357, to_integer('357', 423, 50, 500)
  end

  def test_sub_minimum_value
    assert_equal 50, to_integer('50', 423, 50, 500)
    assert_nil to_integer('49', 423, 50, 500)
  end

  def test_over_maximum_value
    assert_equal 500, to_integer('500', 423, 50, 500)
    assert_nil to_integer('501', 423, 50, 500)
  end
end

#------------------------------------------------------------------------------
# you_have(state)
class YouHave < Test::Unit::TestCase
  self.test_order = :defined

  def setup
    @state = simple_state
  end

  def test_you_have
    hit! @state, :dealer, card(3)
    hit! @state, :dealer, card(10)
    hit! @state, :dealer, card(8)
    hit! @state, :player, card(2)
    hit! @state, :player, card(5)
    hit! @state, :player, card(:A)
    hit! @state, :player, card(2)
    out = capture_stdout { you_have @state }
    assert_equal "You have been dealt <2 5 A 2> for 10 or 20 points.\n", out
  end

  def test_dealer_shows_bust
    hit! @state, :player, card(2)
    hit! @state, :player, card(5)
    hit! @state, :player, card(10)
    hit! @state, :player, card(2)
    hit! @state, :player, card(3)
    out = capture_stdout { you_have @state }
    assert_equal "You have been dealt <2 5 10 2 3> which is a bust.\n", out
  end
end
