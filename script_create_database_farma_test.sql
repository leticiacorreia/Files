DROP DATABASE IF EXISTS farma_test;

CREATE DATABASE farma_test;

\c farma_test;

-- Table: public.users

-- DROP TABLE public.users;

CREATE TABLE public.users
(
  id serial NOT NULL,
  name character varying NOT NULL DEFAULT ''::character varying,
  email character varying NOT NULL DEFAULT ''::character varying,
  encrypted_password character varying NOT NULL DEFAULT ''::character varying,
  reset_password_token character varying,
  reset_password_sent_at timestamp without time zone,
  remember_created_at timestamp without time zone,
  sign_in_count integer NOT NULL DEFAULT 0,
  current_sign_in_at timestamp without time zone,
  last_sign_in_at timestamp without time zone,
  current_sign_in_ip inet,
  last_sign_in_ip inet,
  confirmation_token character varying,
  confirmed_at timestamp without time zone,
  confirmation_sent_at timestamp without time zone,
  unconfirmed_email character varying,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  avatar_file_name character varying,
  avatar_content_type character varying,
  avatar_file_size integer,
  avatar_updated_at timestamp without time zone,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);


-- Table: public.teams

-- DROP TABLE public.teams;

CREATE TABLE public.teams
(
  id serial NOT NULL,
  name character varying,
  code character varying,
  user_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT teams_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_45096701b6 FOREIGN KEY (user_id)
      REFERENCES public.users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- Table: public.users_teams

-- DROP TABLE public.users_teams;

CREATE TABLE public.users_teams
(
  id serial NOT NULL,
  user_id integer,
  team_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT users_teams_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_5b2ee06eaf FOREIGN KEY (user_id)
      REFERENCES public.users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_f4ff17bc5c FOREIGN KEY (team_id)
      REFERENCES public.teams (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Table: public.los

-- DROP TABLE public.los;

CREATE TABLE public.los
(
  id serial NOT NULL,
  name character varying NOT NULL DEFAULT ''::character varying,
  description text NOT NULL DEFAULT ''::text,
  introductions_count integer DEFAULT 0,
  exercises_count integer DEFAULT 0,
  user_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  image_file_name character varying,
  image_content_type character varying,
  image_file_size integer,
  image_updated_at timestamp without time zone,
  modified boolean,
  CONSTRAINT los_pkey PRIMARY KEY (id)
);

-- Table: public.los_teams

-- DROP TABLE public.los_teams;

CREATE TABLE public.los_teams
(
  id serial NOT NULL,
  lo_id integer,
  team_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT los_teams_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_029aa0729a FOREIGN KEY (team_id)
      REFERENCES public.teams (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_5133727c32 FOREIGN KEY (lo_id)
      REFERENCES public.los (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Table: public.introductions

-- DROP TABLE public.introductions;

CREATE TABLE public.introductions
(
  id serial NOT NULL,
  title character varying NOT NULL,
  content text NOT NULL,
  "position" integer,
  lo_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  modified boolean,
  CONSTRAINT introductions_pkey PRIMARY KEY (id)
);

-- Table: public.exercises

-- DROP TABLE public.exercises;

CREATE TABLE public.exercises
(
  id serial NOT NULL,
  title character varying NOT NULL,
  content text NOT NULL,
  "position" integer,
  questions_count integer,
  lo_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  modified boolean,
  CONSTRAINT exercises_pkey PRIMARY KEY (id)
);

-- Table: public.questions

-- DROP TABLE public.questions;

CREATE TABLE public.questions
(
  id serial NOT NULL,
  title character varying NOT NULL,
  "position" integer,
  content text NOT NULL,
  correct_answer text NOT NULL,
  "precision" integer,
  cmas_order boolean,
  exercise_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  modified boolean,
  CONSTRAINT questions_pkey PRIMARY KEY (id)
);

-- Table: public.tips

-- DROP TABLE public.tips;

CREATE TABLE public.tips
(
  id serial NOT NULL,
  content text NOT NULL,
  question_id integer,
  number_of_tries integer DEFAULT 1,
  CONSTRAINT tips_pkey PRIMARY KEY (id)
);

-- Table: public.tips_counts

-- DROP TABLE public.tips_counts;

CREATE TABLE public.tips_counts
(
  id serial NOT NULL,
  tries integer,
  question_id integer,
  user_id integer,
  team_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT tips_counts_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_1e6ffec27a FOREIGN KEY (question_id)
      REFERENCES public.questions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_61fecc5639 FOREIGN KEY (team_id)
      REFERENCES public.teams (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_a51665007a FOREIGN KEY (user_id)
      REFERENCES public.users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- Table: public.los_versions

-- DROP TABLE public.los_versions;

CREATE TABLE public.los_versions
(
  id serial NOT NULL,
  name character varying,
  description text,
  introductions_count integer,
  exercises_count integer,
  image_file_name character varying,
  image_content_type character varying,
  image_file_size integer,
  image_updated_at timestamp without time zone,
  user_id integer,
  lo_id integer,
  created_at timestamp without time zone,
  CONSTRAINT los_versions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_61f1ba4f2f FOREIGN KEY (user_id)
      REFERENCES public.users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_833fc3d513 FOREIGN KEY (lo_id)
      REFERENCES public.los (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);


-- Table: public.introductions_versions

-- DROP TABLE public.introductions_versions;

CREATE TABLE public.introductions_versions
(
  id serial NOT NULL,
  title character varying,
  content text,
  "position" integer,
  lo_id integer,
  introduction_id integer,
  created_at timestamp without time zone,
  CONSTRAINT introductions_versions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_946e84cdc3 FOREIGN KEY (introduction_id)
      REFERENCES public.introductions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Table: public.exercises_versions

-- DROP TABLE public.exercises_versions;

CREATE TABLE public.exercises_versions
(
  id serial NOT NULL,
  title character varying,
  content text,
  "position" integer,
  questions_count integer,
  lo_id integer,
  exercise_id integer,
  created_at timestamp without time zone,
  questions_versions integer[] DEFAULT '{}'::integer[],
  CONSTRAINT exercises_versions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_0355cdb796 FOREIGN KEY (exercise_id)
      REFERENCES public.exercises (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Table: public.questions_versions

-- DROP TABLE public.questions_versions;

CREATE TABLE public.questions_versions
(
  id serial NOT NULL,
  title character varying,
  content text,
  correct_answer text,
  "position" integer,
  "precision" integer,
  cmas_order boolean,
  exercise_id integer,
  question_id integer,
  created_at timestamp without time zone,
  tips_versions integer[] DEFAULT '{}'::integer[],
  CONSTRAINT questions_versions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rails_25df97e31d FOREIGN KEY (question_id)
      REFERENCES public.questions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Table: public.tips_versions

-- DROP TABLE public.tips_versions;

CREATE TABLE public.tips_versions
(
  id serial NOT NULL,
  content character varying,
  number_of_tries integer,
  question_id integer,
  tip_id integer,
  CONSTRAINT tips_versions_pkey PRIMARY KEY (id)
);

-- Table: public.answers

-- DROP TABLE public.answers;

CREATE TABLE public.answers
(
  id serial NOT NULL,
  response text,
  correct boolean,
  attempt_number integer,
  user_id integer,
  question_id integer,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  team_id integer,
  los_version_id integer,
  exercises_version_id integer,
  questions_version_id integer,
  introductions_versions integer[],
  exercises_versions integer[],
  CONSTRAINT answers_pkey PRIMARY KEY (id),
  -- CONSTRAINT fk_rails_36de8718f4 FOREIGN KEY (exercises_version_id)
  --     REFERENCES public.exercises_versions (id) MATCH SIMPLE
  --     ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_3d5ed4418f FOREIGN KEY (question_id)
      REFERENCES public.questions (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_584be190c2 FOREIGN KEY (user_id)
      REFERENCES public.users (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  -- CONSTRAINT fk_rails_5b297fa8fe FOREIGN KEY (los_version_id)
  --     REFERENCES public.los_versions (id) MATCH SIMPLE
  --     ON UPDATE NO ACTION ON DELETE NO ACTION,
  -- CONSTRAINT fk_rails_723892b38b FOREIGN KEY (questions_version_id)
  --     REFERENCES public.questions_versions (id) MATCH SIMPLE
  --     ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_rails_965e763f12 FOREIGN KEY (team_id)
      REFERENCES public.teams (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);



--- Criação de Triggers ---

    DROP TRIGGER IF EXISTS los_versions ON answers;
    DROP FUNCTION IF EXISTS los_versions();

    DROP TRIGGER IF EXISTS introductions_versions ON answers;
    DROP FUNCTION IF EXISTS introductions_versions();

    DROP TRIGGER IF EXISTS exercises_versions ON answers;
    DROP FUNCTION IF EXISTS exercises_versions();

    DROP TRIGGER IF EXISTS questions_versions ON answers;
    DROP FUNCTION IF EXISTS questions_versions();
  
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


  
    CREATE OR REPLACE FUNCTION introductions_versions()
      RETURNS trigger AS
    $BODY$
      DECLARE   
        version_id INTEGER;
        current_lo INTEGER;
        changed BOOLEAN;
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
  
    

    CREATE OR REPLACE FUNCTION exercises_versions()
      RETURNS trigger AS
    $BODY$
      DECLARE   
        version_id INTEGER;
        current_lo INTEGER;
        current_exercise INTEGER; 
        array_exercises INTEGER[];
        array_exercises_versions INTEGER[];
        changed BOOLEAN;
      BEGIN
        -- Salva a versão dos exercícios.

        -- Pega o lo e o exercício corrente.
          SELECT E.lo_id, E.id INTO current_lo, current_exercise
          FROM questions Q, exercises E
          WHERE NEW.question_id = Q.id AND Q.exercise_id = E.id;

          -- Retorna a versão dos exercícios do lo corrente.
          SELECT V.id INTO version_id FROM exercises_versions V WHERE V.lo_id = current_lo;

          IF count(version_id) = 0 THEN
          
          INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
          (SELECT title, content, position, questions_count, lo_id, id 
          FROM exercises
          WHERE current_lo = lo_id);
        
          array_exercises_versions = array(
            SELECT DISTINCT ON (exercise_id) id 
            FROM exercises_versions 
            WHERE lo_id = current_lo 
            ORDER BY exercise_id, id DESC);

          NEW.exercises_versions = array_exercises_versions;

          ELSE
          
          INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
          (SELECT title, content, position, questions_count, lo_id, id 
          FROM exercises 
          WHERE current_lo = lo_id AND modified = true);

          --ter uma forma de pegar somente as versões dos exercícios que foram modificados, para por na array, 
          -- e posteriormente adicionar as versões das questões somente nos exercícios que precisa mudar.
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
          WHERE ex.id = ANY(array_exercises_versions);

          UPDATE exercises SET modified = false WHERE lo_id = current_lo;

          NEW.exercises_versions = array_exercises_versions;
          
        END IF;

        
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
    


    CREATE OR REPLACE FUNCTION questions_versions()
      RETURNS trigger AS
    $BODY$
      DECLARE   
        current_lo INTEGER;
        version_id INTEGER;
        array_exercises INTEGER[];
        array_exercises_versions INTEGER[];
        exercises_of_questions INTEGER[];
        modified_question INTEGER;
        changed BOOLEAN;
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

        -- Retorna em uma array, todas as versões mais recentes dos exercícios deste lo.
        array_exercises_versions = array(
          SELECT DISTINCT ON (exercise_id) id 
          FROM exercises_versions 
          WHERE lo_id = current_lo 
          ORDER BY exercise_id, id DESC); 


          IF count(version_id) = 0 THEN

          INSERT INTO questions_versions(title, content, correct_answer, cmas_order, precision, position, exercise_id, question_id) 
          (SELECT 'Primeira entrada', content, correct_answer, cmas_order, precision, position, exercise_id, id 
          FROM questions as Q
          WHERE Q.exercise_id = ANY(array_exercises));  

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

            
            exercises_of_questions = array(
              SELECT Q.exercise_id
            FROM questions as Q
            WHERE Q.exercise_id = ANY(array_exercises) 
            AND modified = true);
          
          IF array_length(exercises_of_questions, 1) > 0 THEN 
            --ter uma forma de pegar somente as versões dos exercícios que foram modificados, para por na array, 
            -- e posteriormente adicionar as versões das questões somente nos exercícios que precisa mudar.
            INSERT INTO questions_versions(title, content, correct_answer, cmas_order, precision, position, exercise_id, question_id) 
            (SELECT 'Questão Modificada', content, correct_answer, cmas_order, precision, position, exercise_id, id 
            FROM questions as Q
            WHERE Q.exercise_id = ANY(array_exercises) AND modified = true);

            -- cria nova versão do exercício
            INSERT INTO exercises_versions(title, content, position, questions_count, lo_id, exercise_id) 
            (SELECT title, content, position, questions_count, lo_id, id 
            FROM exercises 
            WHERE id = ANY(exercises_of_questions));

            -- Retorna em uma array, todas as versões mais recentes dos exercícios deste lo.
            array_exercises_versions = array(
            SELECT DISTINCT ON (exercise_id) id 
            FROM exercises_versions 
            WHERE exercise_id = ANY(exercises_of_questions) 
            ORDER BY exercise_id, id DESC); 

            UPDATE exercises_versions as ex 
            SET questions_versions = array(
              SELECT DISTINCT ON (question_id) id 
              FROM questions_versions 
              WHERE exercise_id = ex.exercise_id 
              ORDER BY question_id, id DESC)
            WHERE ex.id = ANY(array_exercises_versions);-- and exercise_id = current_exercise_id;

            array_exercises_versions = array(
            SELECT DISTINCT ON (exercise_id) id 
            FROM exercises_versions 
            WHERE lo_id = current_lo 
            ORDER BY exercise_id, id DESC);

            UPDATE questions as Q
            SET modified = false 
            WHERE Q.exercise_id = ANY(exercises_of_questions);

            NEW.exercises_versions = array_exercises_versions;

          END IF;
        
        END IF;

        
        RETURN NEW; 
      END;
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    ALTER FUNCTION exercises_versions()

      OWNER TO postgres;

  

    -- Trigger: on answers
    CREATE TRIGGER questions_versions
      BEFORE INSERT
      ON answers
      FOR EACH ROW
        EXECUTE PROCEDURE questions_versions();
    


    CREATE OR REPLACE FUNCTION tips_versions()
          RETURNS trigger AS
        $BODY$
          DECLARE   
            version_id INTEGER;
            current_lo INTEGER;
            array_tips INTEGER[];
            array_questions_versions INTEGER[];
            changed BOOLEAN;
          BEGIN
            -- pegando o lo corrente...
            SELECT E.lo_id INTO current_lo 
            FROM questions as Q, exercise as E
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
              
              INSERT INTO tips_versions(content, number_of_tries, question_id, tip_id) 
              (SELECT content, number_of_tries, question_id, id
              FROM tips
              WHERE id = ANY(array_tips));
            
              array_questions_versions =  array(
                SELECT DISTINCT ON (Q.id) Q.id  
                FROM questions_versions as Q, exercises as E
                WHERE Q.exercise_id = E.id
                AND E.lo_id = current_lo
                ORDER BY Q.id DESC
                );
              
              UPDATE questions_versions as qv
              SET tips_versions = array(
                SELECT DISTINCT ON (tip_id) id 
                FROM tips_versions 
                WHERE question_id = qv.question_id 
                ORDER BY tip_id, id DESC)
              WHERE qv.id = ANY(array_questions_versions);


              ELSE
              
              
              
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
