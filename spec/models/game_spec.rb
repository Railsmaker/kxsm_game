require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  # Пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # Игра с прописанными игровыми вопросами
  let(:game_w_questions) {FactoryBot.create(:game_with_questions, user: user)}

  context 'finishes game if take money' do
    it 'take_money! finishes the game' do
      # извлекаем текущий игровой вопрос и даём ответ
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      # взяли деньги
      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      # проверяем что закончилась игра и пришли деньги игроку
      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # Генерим 60 вопросов с 4х запасом по полю level, чтобы проверить работу
      # RANDOM при создании игры.
      generate_questions(60)

      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
        # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
          # Game.count не должен измениться
          change(Question, :count).by(0)
        )
      )

      # Проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # Тесты на основную игровую логику
  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Текущий уровень игры и статус
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)

      # Ранее текущий вопрос стал предыдущим
      expect(game_w_questions.current_game_question).not_to eq(q)

      # Игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end

  # группа тестов на проверку статуса игры
  context '.status' do
    # перед каждым тестом "завершаем игру"
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  # возвращает валидный экземпляр из модели GameQuestion
  context '#current_game_question' do
    let(:game_with_questions){FactoryBot.create :game_with_questions, current_level: 7}

    it 'return valid instance of GameQuestion' do
      current_game_q = game_with_questions.game_questions[7]
      expect(game_with_questions.current_game_question).to eq current_game_q
    end
  end

  context '#previous_level' do
    let(:game_with_questions){FactoryBot.create :game_with_questions, current_level: 5}

    it 'when the current level > previous level' do
      expect(game_with_questions.previous_level).to eq 4
    end
  end

  context '#answer_current_question!' do
    let(:game_with_questions){FactoryBot.create :game_with_questions, current_level: 5}

    it 'when the user answered correctly' do
      # return true
      expect(game_with_questions.answer_current_question!('d')).to eq true
      # game status
      expect(game_with_questions.status).to eq :in_progress
      # increment game level
      expect(game_with_questions.current_level).to eq 6
    end

    it 'when the answer is wrong' do
      # return false
      expect(game_with_questions.answer_current_question!('a')).to eq false
      # fails the game
      expect(game_with_questions.status).to eq :fail
      # updates prize
      expect(game_with_questions.prize).to eq 1_000
      # game level
      expect(game_with_questions.current_level).to eq 5
    end

    it 'when is the last answer' do
      15.times do
        game_with_questions.answer_current_question!('d')
      end
      # the prize amount million
      expect(game_with_questions.prize).to eq 1_000_000
      # return "false" for timed out answer
      expect(game_with_questions.is_failed).to be false
    end

    it 'when game time is over' do
      game_with_questions.created_at =  Time.now - 36.minutes
      expect(game_with_questions.time_out!).to be true
      # fails the game
      expect(game_with_questions.status).to eq :timeout
    end
  end
end
