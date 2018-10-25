require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: она будет создана на фабрике заново для каждого блока it,
  # где она вызывается.
  let(:game_question) {FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3)}

  # тест на наличие методов делегатов level и text
  it 'correct .level & .text delegates' do
    expect(game_question.text).to eq(game_question.question.text)
    expect(game_question.level).to eq(game_question.question.level)
  end

  # Группа тестов на игровое состояние объекта вопроса
  context 'game status' do
    # Тест на правильную генерацию хэша с вариантами
    it 'correct .variants' do
      expect(game_question.variants).to eq(
        'a' => game_question.question.answer2,
        'b' => game_question.question.answer1,
        'c' => game_question.question.answer4,
        'd' => game_question.question.answer3
      )
    end

    it 'correct .answer_correct?' do
      # Именно под буквой b в тесте спрятан указатель на верный ответ
      expect(game_question.answer_correct?('b')).to be_truthy
    end
  end

  context 'answer choice' do
    # Возвращает правильный ответ, букву.
    it 'correct .correct_answer_key' do
      expect(game_question.correct_answer_key).to eq 'b'
    end
  end

  context 'user helpers' do
    it '#add_audience_help' do
      expect(game_question.help_hash).not_to include(:audience_help)
      game_question.add_audience_help
      expect(game_question.help_hash).to include(:audience_help)
      # audience_help: {'a' => 42, 'c' => 37 ...}
      ah = game_question.help_hash[:audience_help]
      expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
    end

    it '#add_fifty_fifty' do
      expect(game_question.help_hash).not_to include(:fifty_fifty)
      game_question.add_fifty_fifty
      expect(game_question.help_hash).to include(:fifty_fifty)
      # fifty_fifty: ['a', 'b']
      expect(game_question.help_hash[:fifty_fifty].size).to eq(2)
      expect(game_question.help_hash[:fifty_fifty]).to include('b')
    end

    it '#add_friend_call' do
      expect(game_question.help_hash).not_to include(:friend_call)
      game_question.add_friend_call
      game_question.help_hash[:friend_call] = 'Подсказка друга, ответ: А'
      expect(game_question.help_hash).to include(:friend_call)
      #  friend_call: Подсказка друга, ответ: А
      expect(game_question.help_hash[:friend_call]).to be
      expect(game_question.help_hash).to eq({friend_call: 'Подсказка друга, ответ: А'})
    end
  end
end
