#11.06
- ux 디자인
    - 화면 1 : 입력하는 화면
        - 우선
            - 1-10까지의 숫자 및 표정이 들어있는 불연속적인 블럭
            - ![vas scale](https://www.wikidoc.org/images/e/eb/Pain_scale.jpg)
            - 1 2 3 4 5 6 7 8 9 10 
            - 🙂🙁😟😞😣😖🤒🤕🤢
       
        - 추후
            - scrollabe로 숫자 및 표정이 가운데 애니메이션같이 자연스럽 넘어가게 표시되게
  	- 시간은 분없이 시간만 선택, 디폴트표시되고 확인, 까먹은거는 조절가능하게   
    - 화면 2 시각화로 보여주는 화면
        - x축 약먹은 시간(오늘날짜가 맨 오른쪽인게 핵심)
        - y축 통증 점수	
- 백
- db
    Sqlite
        - user
        - 시간
        - 점수
    - 추후 
        - credential, security
- general
    - 환자가 가진 병(암성통증인지 관절통증인지), 진통제 종류 분류되서 스트링이 아닌 분류로 저장되게 해야
    - 속효성진통제, 지속형을 얼마나 먹었는지
	- 어떻게 용량을 늘리면 좋을지!! 제안하기 ai? or logic?
    - 의사용화면웹
