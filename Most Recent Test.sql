SELECT * FROM (
---testetstests
    SELECT
        student.SystemStudentID,
        custenroll.FullName,
		custenroll.GradeLevel_Numeric AS GradeLevel,
		studenthist.GradeLevel_Numeric AS GradeLevel_Historical,
		test.TestName,
        test.TestPeriod,
		custenroll.SchoolName,
        custenroll.SchoolLevel,
        custenroll.SchoolRegion,
		schoolcal.SchoolYear,
        schoolcal.FullDate,
		custenroll.AdvisoryGroup,
        fact.TestScore Lexile,
        fact.LastUpdated AS STARLastUpdated,

        RANK() OVER (
            PARTITION BY
                student.SystemStudentID
            ORDER BY
                schoolcal.FullDate DESC,
                fact.TestScore DESC,                                    --fact.TestSCore serves as a tiebreaker
                fact.ID DESC                                            --fact.ID serves as a tiebreaker
	) LexileCustomScoreRank

    FROM dw.DW_factTestScores fact
    LEFT JOIN dw.DW_dimSchoolCalendar schoolcal
        ON fact.SchoolCalendarKey = schoolcal.SchoolCalendarKey
    LEFT JOIN dw.DW_dimStudent student 
        ON fact.StudentKey = student.StudentKey
    LEFT JOIN dw.DW_dimStudentHistorical studenthist
        ON fact.StudentHistoricalKey = studenthist.StudentHistoricalKey
    LEFT JOIN dw.DW_dimTest test
        ON fact.TestKey = test.TestKey
    LEFT JOIN dw.DW_dimTestProficiencyLevel testprof
        ON fact.TestProficiencyLevelKey = testprof.TestProficiencyLevelKey
    LEFT JOIN custom.Custom_EnrollmentbyLatestData custenroll
        ON student.SystemStudentID = custenroll.SystemStudentID

    WHERE test.TestName = 'STAR Reading'
	AND test.TestScoreType = 'Test'

) OuterQuery

WHERE LexileCustomScoreRank = 1                                       --to only keep one row per student