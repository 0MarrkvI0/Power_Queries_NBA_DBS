SELECT
    id AS player_id,
    first_name,
    last_name,

    SUM(
        CASE
            WHEN event_msg_type = 'FIELD_GOAL_MADE' THEN margin_difference
            WHEN event_msg_type = 'FREE_THROW' AND margin_difference IS NOT NULL THEN margin_difference
            ELSE 0
        END
    ) AS points,

    COUNT(
        CASE
            WHEN margin_difference = 2 THEN 1
            ELSE NULL
        END
    ) AS "2PM",

    COUNT(
        CASE
            WHEN margin_difference = 3 THEN 1
            ELSE NULL
        END
    ) AS "3PM",

    COUNT(
        CASE
            WHEN event_msg_type = 'FIELD_GOAL_MISSED' THEN 1
            ELSE NULL
        END
    ) AS missed_shots,

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN event_msg_type = 'FIELD_GOAL_MADE' THEN 1
                    ELSE 0
                END
            )::numeric /
            NULLIF(
                SUM(
                    CASE
                        WHEN event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED') THEN 1
                        ELSE 0
                    END
                ), 0
            ) * 100,
            2
        ),
        0
    ) AS shooting_percentage,

    COUNT(
        CASE
            WHEN event_msg_type = 'FREE_THROW' AND margin_difference = 1 THEN 1
            ELSE NULL
        END
    ) AS "FTM",

    COUNT(
        CASE
            WHEN event_msg_type = 'FREE_THROW' AND margin_difference IS NULL THEN 1
            ELSE NULL
        END
    ) AS missed_free_throws,

    COALESCE(
        ROUND(
            SUM(
                CASE
                    WHEN event_msg_type = 'FREE_THROW' AND margin_difference = 1 THEN 1
                    ELSE 0
                END
            )::numeric /
            NULLIF(
                SUM(
                    CASE
                        WHEN event_msg_type = 'FREE_THROW' THEN 1
                        ELSE 0
                    END
                ), 0
            ) * 100,
            2
        ),
        0
    ) AS "FT_percentage"

FROM (
    SELECT
        p.id,
        p.first_name,
        p.last_name,
        pr2.event_msg_type,
        subquery.margin_difference
    FROM (
        SELECT
            pr.game_id,
            pr.event_msg_type,
            pr.event_number,
            pr.score,
            CASE
                WHEN pr.score_margin = 'TIE' THEN 0
                ELSE CAST(pr.score_margin AS INTEGER)
            END AS score_margin,

            COALESCE(
                LAG(
                    CASE
                        WHEN pr.score_margin = 'TIE' THEN 0
                        ELSE CAST(pr.score_margin AS INTEGER)
                    END
                ) OVER (ORDER BY pr.event_number),
                0
            ) AS previous_score_margin,

            ABS(
                CASE
                    WHEN pr.score_margin = 'TIE' THEN 0
                    ELSE CAST(pr.score_margin AS INTEGER)
                END -
                COALESCE(
                    LAG(
                        CASE
                            WHEN pr.score_margin = 'TIE' THEN 0
                            ELSE CAST(pr.score_margin AS INTEGER)
                        END
                    ) OVER (ORDER BY pr.event_number),
                    0
                )
            ) AS margin_difference

        FROM play_records AS pr
        WHERE
            pr.game_id = 21701185
            AND pr.score_margin IS NOT NULL
    ) AS subquery
    RIGHT JOIN play_records AS pr2
        ON pr2.event_number = subquery.event_number
    JOIN players AS p
        ON pr2.player1_id = p.id
    WHERE
        pr2.game_id = 21701185
) AS game_players

WHERE event_msg_type IN ('FREE_THROW', 'FIELD_GOAL_MISSED', 'FIELD_GOAL_MADE')
GROUP BY first_name, last_name, id
ORDER BY points DESC, shooting_percentage DESC, "FT_percentage" DESC, player_id;
