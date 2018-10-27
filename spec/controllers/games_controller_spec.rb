require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do

  let(:user){FactoryBot.create(:user)}
  let(:admin){FactoryBot.create(:user, is_admin: true)}
  let(:game_w_questions){FactoryBot.create(:game_with_questions, user: user)}

  context 'Anonymous user:' do
    it '#show.' do
      get :show, id: game_w_questions.id

      # недолжна вернуться успешная страница
      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it '#show. without user registration' do
      get :show, id: game_w_questions.id

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq 'Вам необходимо войти в систему или зарегистрироваться.'
    end

    it '#create. without user registration' do
      post :create

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq 'Вам необходимо войти в систему или зарегистрироваться.'
    end

    it '#answer. without user registration' do
      put :answer, id: game_w_questions, params: {letter: 'a'}

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq 'Вам необходимо войти в систему или зарегистрироваться.'
    end

    it '#take_money. without user registration' do
      put :take_money, id: game_w_questions.id

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq 'Вам необходимо войти в систему или зарегистрироваться.'
    end

  end

  context 'Logged in user:' do
    before(:each)do
      sign_in user
    end

    it 'creates game' do
      generate_questions(60)
      post :create
      # instance переменная @game
      game = assigns(:game)
      # проверяем состояние игры
      expect(game.finished?).to be_falsey
      expect(game.user).to eq user

      expect(response).to redirect_to game_path(game)
      expect(flash[:notice]).to be
    end

    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.user).to eq user
      expect(response.status).to eq 200
      expect(response).to render_template('show')
    end

    it 'answer correct' do
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy
    end

    it 'answer wrong' do
      put :answer, id: game_w_questions.id, params: {letter: 'a'}
      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(game.current_level).to eq 0
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
    end

    # проверка, пользователь не может играть в чужую игру
    it '#show alien game' do
      alien_game = FactoryBot.create(:game_with_questions)
      get :show, id: alien_game.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be
    end

    # юзер берет деньги
    it 'takes money' do
      # вручную поднимем уровень вопроса до выигрыша 200
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, id: game_w_questions.id
      game = assigns(:game)
      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(200)

      # пользователь изменился в базе, надо в коде перезагрузить!
      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    # игра закончилась проигрышем
    it 'when game over' do
      put :answer, id: game_w_questions.id, params: {letter: 'a'}
      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
    end

    # юзер пытается создать новую игру, не закончив старую
    it 'try to create second game' do
      # убедились что есть игра в работе
      expect(game_w_questions.finished?).to be_falsey

      # отправляем запрос на создание, убеждаемся что новых Game не создалось
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game).to be_nil

      # и редирект на страницу старой игры
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end

    # 50/50 подсказка
    it 'fifty_fifty is available' do
      expect(game_w_questions.fifty_fifty_used).to be_falsey
      expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be

      put :help, id: game_w_questions.id, help_type: :fifty_fifty
      game = assigns(:game)

      expect(game.fifty_fifty_used).to be_truthy
      expect(game.current_game_question.help_hash[:fifty_fifty]).to be

      expect(response).to redirect_to(game_path(game))
      expect(response.status).to eq(302)

      expect(flash[:info]).to eq('Вы использовали подсказку')
    end
  end
end
