# db/migrate/20161001192022_create_versions_triggers.rb
class CreateVersionsTriggers < ActiveRecord::Migration
  def up
    introductions_versions
    exercises_versions
    questions_versions
    tips_versions
    los_versions
    wlast_answers
  end

  def down
    execute <<-SQL
	    DROP TRIGGER IF EXISTS los_versions ON answers;
	    DROP FUNCTION IF EXISTS los_versions();

		DROP TRIGGER IF EXISTS introductions_versions ON answers;
		DROP FUNCTION IF EXISTS introductions_versions();

		DROP TRIGGER IF EXISTS exercises_versions ON answers;
		DROP FUNCTION IF EXISTS exercises_versions();

		DROP TRIGGER IF EXISTS questions_versions ON answers;
		DROP FUNCTION IF EXISTS questions_versions();

		DROP TRIGGER IF EXISTS tips_versions ON answers;
		DROP FUNCTION IF EXISTS tips_versions();

		DROP VIEW IF EXISTS answer_view;
	
		DROP TRIGGER IF EXISTS wlast_answers ON answers;
		DROP FUNCTION IF EXISTS wlast_answers();
 	SQL

 	#delete from answers;
	#delete from tips_counts;
	#delete from los_versions;
	#delete from introductions_versions;
	#delete from exercises_versions;
	#delete from questions_versions;
  end

  def los_versions
    execute <<-SQL
    	CREATE OR REPLACE FUNCTION los_versions()
		  RETURNS trigger AS
		$BODY$
			DECLARE 	
				version_id INTEGER;
				current_lo INTEGER;
				changed    BOOLEAN;
			BEGIN
				--Recupera o LO corrente;
				SELECT e.lo_id INTO current_lo
			    FROM questions q, exercises e
			    WHERE q.exercise_id = e.id AND NEW.question_id = q.id;
			    --Retorna a versão mais recente do LO (se esta existir), e também se o LO corrente foi modificado.
				SELECT lv.id INTO version_id 
				FROM los_versions lv 
				WHERE lv.lo_id = current_lo 
				ORDER BY lv.id DESC;

				SELECT modified INTO changed FROM los WHERE current_lo = id;
    
				IF count(version_id) = 0 OR changed = true THEN 
					INSERT INTO los_versions (name, description, introductions_count, exercises_count, 
						image_file_name, image_content_type,
						image_file_size, image_updated_at, user_id, lo_id)
						SELECT name, description, introductions_count, exercises_count, 
						image_file_name, image_content_type,
						image_file_size, image_updated_at, user_id, id 
					FROM los 
					WHERE current_lo = id RETURNING id INTO version_id;
				
					IF changed = TRUE THEN				
						UPDATE los SET modified = false WHERE id = current_lo;
					END IF;

					NEW.los_version_id = version_id;
				ELSE 
					-- Só retorna a versão mais recente do LO:
					NEW.los_version_id = version_id;
				END IF;

				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION los_versions()
		  OWNER TO postgres;

	

		-- Trigger: on answers
		CREATE TRIGGER los_versions
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE los_versions();
    SQL
  end

  def introductions_versions
  	execute <<-SQL
    	CREATE OR REPLACE FUNCTION introductions_versions()
		  RETURNS trigger AS
		$BODY$
			DECLARE 	
				version_id INTEGER;
				current_lo INTEGER;
				--introductions_id BIGINT[];
			BEGIN
				--pega o LO da resposta corrente:
				SELECT E.lo_id INTO current_lo
			    FROM questions Q, exercises E
			    WHERE NEW.question_id = Q.id AND Q.exercise_id = E.id;

			    -- retorna a versão da introdução:
			    SELECT I.id INTO version_id FROM introductions_versions I WHERE I.lo_id = current_lo;

			    -- Se não existir versão, salva versão de todas as introduções, 
			    -- Se já existir, então salva somente as introduções que foram modificadas.
			    IF count(version_id) = 0 THEN
					
					INSERT INTO introductions_versions(title, content, position, lo_id, introduction_id) 
					(SELECT title, content, position, lo_id, id 
					FROM introductions 
					WHERE current_lo = lo_id);
					-- /seria a continuação do where: RETURNING id INTO introductions_id;
											
			    ELSE
					INSERT INTO introductions_versions(title, content, position, lo_id, introduction_id) 
					(SELECT title, content, position, lo_id, id 
					FROM introductions 
					WHERE current_lo = lo_id AND modified = true);

					UPDATE introductions SET modified = false WHERE lo_id = current_lo;
				END IF;

				-- Adiciona as versões mais recentes das introduções deste LO na resposta:
				NEW.introductions_versions = array(
						SELECT DISTINCT ON (introduction_id) id 
						FROM introductions_versions 
						WHERE lo_id = current_lo
						ORDER BY introduction_id, id DESC);
				
				-- retorna a resposta.
				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION introductions_versions()

		  OWNER TO postgres;

		-- Trigger: on answers
		CREATE TRIGGER introductions_versions
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE introductions_versions();
    SQL
  end

  def exercises_versions
  	execute <<-SQL
    	CREATE OR REPLACE FUNCTION exercises_versions()
		  RETURNS trigger AS
		$BODY$
			DECLARE 	
				version_id INTEGER;
				current_lo INTEGER;
				current_exercise INTEGER;	
				array_exercises INTEGER[];
				array_exercises_versions INTEGER[];
				array_exercises_modified INTEGER[];
			BEGIN
				-- Salva a versão dos exercícios.

				-- Pega o lo e o exercício corrente.
			    SELECT E.lo_id, E.id INTO current_lo, current_exercise
			    FROM questions Q, exercises E
			    WHERE NEW.question_id = Q.id AND Q.exercise_id = E.id;

			    -- Retorna a versão dos exercícios do lo corrente.
			    SELECT V.id INTO version_id 
			    FROM exercises_versions V 
			    WHERE V.lo_id = current_lo;

			    IF count(version_id) = 0 THEN
					
					INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
					(SELECT title, content, position, questions_count, lo_id, id 
					FROM exercises
					WHERE current_lo = lo_id);
				
			    ELSE
					array_exercises_modified =  array(
						SELECT id 
						FROM exercises
						WHERE lo_id = current_lo AND modified = true
						);

					INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
					(SELECT title, content, position, questions_count, lo_id, id 
					FROM exercises 
					WHERE id = ANY(array_exercises_modified));

					--ter uma forma de pegar somente as versões dos exercícios que foram modificados, para por na array, 
					-- e posteriormente adicionar as versões das questões somente nos exercícios que precisa mudar.
					array_exercises_versions = array(
						SELECT DISTINCT ON (exercise_id) id 
						FROM exercises_versions 
						WHERE exercise_id = ANY(array_exercises_modified) 
						ORDER BY exercise_id, id DESC);

					UPDATE exercises_versions as ex 
					SET questions_versions = array(
						SELECT DISTINCT ON (question_id) id 
						FROM questions_versions 
						WHERE exercise_id = ex.exercise_id 
						ORDER BY question_id, id DESC)
					WHERE ex.id = ANY(array_exercises_versions);

					UPDATE exercises 
					SET modified = false 
					WHERE id = ANY(array_exercises_modified);
					
				END IF;

				array_exercises_versions = array(
					SELECT DISTINCT ON (exercise_id) id 
					FROM exercises_versions 
					WHERE lo_id = current_lo 
					ORDER BY exercise_id, id DESC
				);

				NEW.exercises_versions = array_exercises_versions;

				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION exercises_versions()

		  OWNER TO postgres;

	

		-- Trigger: on answers
		CREATE TRIGGER exercises_versions
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE exercises_versions();
    SQL
  end

  def questions_versions
  	execute <<-SQL
    	CREATE OR REPLACE FUNCTION questions_versions()
		  RETURNS trigger AS
		$BODY$
			DECLARE 	
				current_lo INTEGER;
				version_id INTEGER;
				array_exercises INTEGER[];
				array_exercises_versions INTEGER[];
				exercises_of_questions_modified INTEGER[];
				array_questions_modified INTEGER[];
				array_versions_questions_modified INTEGER[];
			BEGIN
				SELECT E.lo_id INTO current_lo
			    FROM questions Q, exercises E
			    WHERE NEW.question_id = Q.id AND Q.exercise_id = E.id;

			    -- Retorna as versões das questões que são do lo corrente.
			    SELECT Q.id INTO version_id 
			    FROM questions_versions Q, exercises_versions E
			    WHERE Q.exercise_id = E.exercise_id AND E.lo_id = current_lo;

				-- seleciona todos os exercicios para posteriormente pegar as questões..
			    array_exercises = array(
						SELECT id
					    FROM exercises
						WHERE lo_id = current_lo);	


			    IF count(version_id) = 0 THEN

					INSERT INTO questions_versions(title, content, correct_answer, cmas_order, precision, position, exercise_id, question_id) 
					(SELECT 'Primeira entrada', content, correct_answer, cmas_order, precision, position, exercise_id, id 
					FROM questions as Q
					WHERE Q.exercise_id = ANY(array_exercises));	

					-- Retorna em uma array, todas as versões mais recentes dos exercícios deste lo.
					array_exercises_versions = array(
					SELECT DISTINCT ON (exercise_id) id 
					FROM exercises_versions 
					WHERE lo_id = current_lo 
					ORDER BY exercise_id, id DESC);

					UPDATE exercises_versions as ex 
					SET questions_versions = array(
						SELECT DISTINCT ON (question_id) id 
						FROM questions_versions 
						WHERE exercise_id = ex.exercise_id 
						ORDER BY question_id, id DESC)
					WHERE ex.id = ANY(array_exercises_versions);-- and exercise_id = current_exercise_id;

					

			    ELSE
			    	-- Se existir alguma questão que necessita atualizar a versão, então cria uma nova versão dessa questão
			    	-- e também cria uma nova versão do exercício associado a essa questão, e atrela ela a nova versão do exercício.

			    	array_questions_modified = array(
						SELECT id
						FROM questions
						WHERE exercise_id = ANY(array_exercises) 
						AND modified = true);

		    		exercises_of_questions_modified = array(
		    			SELECT exercise_id
						FROM questions
						WHERE id = ANY(array_questions_modified));
					
					
					IF array_length(array_questions_modified, 1) > 0 THEN 
						--ter uma forma de pegar somente as versões dos exercícios que foram modificados, para por na array, 
						-- e posteriormente adicionar as versões das questões somente nos exercícios que precisa mudar.
						INSERT INTO questions_versions(title, content, correct_answer, cmas_order, precision, position, exercise_id, question_id) 
						(SELECT 'Questão Modificada', content, correct_answer, cmas_order, precision, position, exercise_id, id 
						FROM questions as Q
						WHERE Q.id = ANY(array_questions_modified)
						);

						-- cria nova versão do exercício
						INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
						(SELECT title, content, position, questions_count, lo_id, id 
						FROM exercises 
						WHERE id = ANY(exercises_of_questions_modified)
						);

						-- Adiciona na array somente as versões recém-criadas dos exercícios (que a questão foi modificada).
						array_exercises_versions = array(
						SELECT DISTINCT ON (exercise_id) id 
						FROM exercises_versions 
						WHERE exercise_id = ANY(exercises_of_questions_modified) 
						ORDER BY exercise_id, id DESC);	

						-- Atualiza as versões dos exercícios com as suas respectivas questões..
						UPDATE exercises_versions as ex 
						SET questions_versions = array(
							SELECT DISTINCT ON (question_id) id 
							FROM questions_versions 
							WHERE exercise_id = ex.exercise_id 
							ORDER BY question_id, id DESC)
						WHERE ex.id = ANY(array_exercises_versions);-- and exercise_id = current_exercise_id;

						-- Adiciona na array as versões mais recentes de todos os exercícios pertencentes à este lo.
						array_exercises_versions = array(
						SELECT DISTINCT ON (exercise_id) id 
						FROM exercises_versions 
						WHERE lo_id = current_lo 
						ORDER BY exercise_id, id DESC);

						NEW.exercises_versions = array_exercises_versions;

						-- Retorna as versões mais recentes das questões que foram modificadas..
						array_versions_questions_modified = array(
							SELECT DISTINCT ON (question_id) id 
							FROM questions_versions
							WHERE question_id = ANY(array_questions_modified)
							ORDER BY question_id, id DESC);

						-- Adiciona as dicas para cada questão que foi modificada..
						UPDATE questions_versions as qv
						SET tips_versions = array(
							SELECT DISTINCT ON (tip_id) id
							FROM tips_versions
							WHERE question_id = qv.question_id
							ORDER BY tip_id, id DESC)
						WHERE qv.id = ANY(array_versions_questions_modified);

						UPDATE questions 
						SET modified = false 
						WHERE id = ANY(array_questions_modified);

					END IF;
				

				END IF;


				UPDATE questions
				SET title = 'questão modificada na função questions_versions.'
				WHERE id = NEW.question_id;
				
				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION questions_versions()

		  OWNER TO postgres;

	

		-- Trigger: on answers
		CREATE TRIGGER questions_versions
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE questions_versions();
    SQL
  end

  def tips_versions
  	execute <<-SQL
    	CREATE OR REPLACE FUNCTION tips_versions()
		  RETURNS trigger AS
		$BODY$
			DECLARE 	
				version_id INTEGER;
				current_lo INTEGER;
				array_tips INTEGER[];
				array_questions_versions INTEGER[];
				array_questions_for_created INTEGER[];
				array_exercises_versions INTEGER[];
				tip_modified INTEGER;
			BEGIN
				-- pegando o lo corrente...
				SELECT E.lo_id INTO current_lo 
				FROM questions as Q, exercises as E
				WHERE NEW.question_id = Q.id 
				AND Q.exercise_id = E.id;
				
				-- pegando todas as dicas do LO desta resposta..
			    array_tips = array(
			    	SELECT T.id 
			    	FROM tips T, questions Q, exercises E
			    	WHERE T.question_id = Q.id 
			    	  AND Q.exercise_id = E.id 
			    	  AND E.lo_id = current_lo
			    	);

			    SELECT V.id INTO version_id FROM tips_versions V WHERE V.tip_id = ANY(array_tips);

			    IF count(version_id) = 0 THEN
					
					-- Insere a versão para todas as dicas deste lo..
					INSERT INTO tips_versions(content, number_of_tries, question_id, tip_id) 
					(SELECT content, number_of_tries, question_id, id
					FROM tips
					WHERE id = ANY(array_tips));
			
					-- Adiciona na array as versões mais recentes das questões pertencentes à este lo.
					array_questions_versions =  array(
						SELECT DISTINCT ON (Q.id) Q.id  
						FROM questions_versions as Q, exercises as E
						WHERE Q.exercise_id = E.id
						AND E.lo_id = current_lo
						ORDER BY Q.id DESC
						);
					
					-- Atualiza as versões mais recentes das questões com as dicas correspondentes de cada questão.
					UPDATE questions_versions as qv
					SET tips_versions = array(
						SELECT DISTINCT ON (tip_id) id 
						FROM tips_versions 
						WHERE question_id = qv.question_id 
						ORDER BY tip_id, id DESC)
					WHERE qv.id = ANY(array_questions_versions);


			    ELSE
			    	--Adiciona na array todas as questões das dicas que foram modificadas neste lo..
					array_questions_for_created = array(
						SELECT T.question_id 
						FROM tips as T
						WHERE T.id = ANY(array_tips) AND modified = true
						);


					INSERT INTO tips_versions(content, number_of_tries, question_id, tip_id) 
					(SELECT content, number_of_tries, question_id, id 
					FROM tips
					WHERE id = ANY(array_tips) AND modified = true);
				
					--- Cria uma nova versão das questões onde a dica foi modificada.
					INSERT INTO questions_versions(title, content, correct_answer, cmas_order, precision, position, exercise_id, question_id) 
						(SELECT 'Questão Modificada dentro da Dica', content, correct_answer, cmas_order, precision, position, exercise_id, id 
						FROM questions as Q
						WHERE Q.id = ANY(array_questions_for_created)
						);

					-- Adiciona na array as versões mais recentes das questões referentes as dicas modificadas..
					array_questions_versions = array(
						SELECT DISTINCT ON (Q.question_id) Q.id  
						FROM questions_versions as Q
						WHERE Q.question_id = ANY(array_questions_for_created)
						ORDER BY Q.question_id, Q.id DESC
						);

					-- Modifica somente as versões das questões referentes as dicas modificadas..
					UPDATE questions_versions as qv
					SET tips_versions = array(
						SELECT DISTINCT ON (tip_id) id 
						FROM tips_versions 
						WHERE question_id = qv.question_id 
						ORDER BY tip_id, id DESC)
					WHERE qv.id = ANY(array_questions_versions);

					-- Cria versão dos exercicios das questões referentes as dicas modificadas
					INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id)
						(SELECT E.title, E.content, E.position, E.questions_count, E.lo_id, E.id
						FROM exercises as E, questions as Q
						WHERE E.id = Q.exercise_id AND Q.id = ANY(array_questions_for_created)
						);
					
					-- Adiciona na array as versões novas dos exercícios referentes as questões que foram criadas recentemente.
					array_exercises_versions = array(
						SELECT DISTINCT ON (E.exercise_id) E.id  
						FROM exercises_versions as E, questions as Q
						WHERE E.exercise_id = Q.exercise_id AND Q.id = ANY(array_questions_for_created)
						ORDER BY E.exercise_id, E.id DESC
						);

					-- adiciona nos exercicios destas questoes, as versões mais recentes de todas as questões deste lo...
					UPDATE exercises_versions as ev
					SET questions_versions = array(
						SELECT DISTINCT ON (Q.question_id) Q.id  
						FROM questions_versions as Q, exercises as E
						WHERE Q.exercise_id = E.id
						AND E.lo_id = current_lo
						ORDER BY Q.question_id, Q.id DESC)
					WHERE ev.id = ANY(array_exercises_versions);

					-- adiciona na array as versões mais recentes de todos os exercícios deste lo..
					array_exercises_versions = array(
						SELECT DISTINCT ON (E.exercise_id) E.id  
						FROM exercises_versions as E
						WHERE E.lo_id = current_lo
						ORDER BY E.exercise_id, E.id DESC
						);

					NEW.exercises_versions = array_exercises_versions;

					UPDATE tips 
					SET modified = false 
					WHERE id = ANY(array_tips);
				END IF;

				
				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION tips_versions()

		  OWNER TO postgres;

	

		-- Trigger: on answers
		CREATE TRIGGER tips_versions
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE tips_versions();
    SQL
  end

 def wlast_answers
    execute <<-SQL
    	CREATE OR REPLACE FUNCTION wlast_answers()
		  RETURNS trigger AS
		$BODY$
			DECLARE
				array_answers INTEGER[]; 	
				array_versions_questions INTEGER[];
				current_lo INTEGER;
			BEGIN
				-- pegando o lo corrente...
				SELECT E.lo_id INTO current_lo 
				FROM questions as Q, exercises as E
				WHERE NEW.question_id = Q.id 
				AND Q.exercise_id = E.id;

				array_versions_questions = array(
					SELECT DISTINCT ON (Q.question_id) Q.id 
					FROM questions_versions as Q, exercises as E
					WHERE Q.exercise_id = E.id 
					AND E.lo_id = current_lo
					ORDER BY Q.question_id, Q.id DESC
					);

				NEW.questions_version_id = (
					SELECT DISTINCT ON (Q.question_id) Q.id 
					FROM questions_versions as Q
					WHERE NEW.question_id = Q.question_id
					ORDER BY Q.question_id, Q.id DESC);

				NEW.exercises_version_id = (
					SELECT DISTINCT ON (E.exercise_id) E.id 
					FROM exercises_versions as E, questions as Q
					WHERE NEW.question_id = Q.id AND Q.exercise_id = E.exercise_id
					ORDER BY E.exercise_id, E.id DESC
					);
				

				array_answers = array(
					SELECT id 
					FROM answers 
					WHERE questions_version_id = ANY(array_versions_questions)
					AND team_id = NEW.team_id
					);
				
				NEW.last_answers = array_answers;
				RETURN NEW; 
			END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;
		ALTER FUNCTION wlast_answers()
		  OWNER TO postgres;

	

		-- Trigger: on answers
		CREATE TRIGGER wlast_answers
		  BEFORE INSERT
		  ON answers
		  FOR EACH ROW
			  EXECUTE PROCEDURE wlast_answers();
    SQL
  end
end


# def last_answers
  #   execute <<-SQL
  #   	CREATE OR REPLACE FUNCTION last_answers()
		#   RETURNS trigger AS
		# $BODY$
		# 	DECLARE 	
		# 		current_lo INTEGER;
		# 	BEGIN
					
		# 		RETURN NEW; 
		# 	END;
		# $BODY$
		#   LANGUAGE plpgsql VOLATILE
		#   COST 100;
		# ALTER FUNCTION last_answers()
		#   OWNER TO postgres;

	

		# -- Trigger: on answers
		# CREATE TRIGGER last_answers
		#   BEFORE INSERT
		#   ON answers
		#   FOR EACH ROW
		# 	  EXECUTE PROCEDURE last_answers();
  #   SQL
  # end
